Complete Gnus
=============

This repo demonstrate one *complete* and *working* solution to
reading/writing mails in Gnus, with the help of `offlineimap`,
`dovecot`, `msmtp` and `cron`.  Concretely, this repo contains

1. necessary configuration files for each component,
2. a brief summary of the big picture and detailed explanation on how
   the components work together, and
3. helpful resource links.

*Note: although this solution is tested under Ubuntu, it should work
fine for all Linux distributions provided each component be properly
installed.*

## Dependecies ##

1. gnus. http://www.gnus.org/
2. offlineimap. http://www.offlineimap.org/
3. dovecot. https://www.dovecot.org/
4. msmtp. http://msmtp.sourceforge.net/
5. cron. https://directory.fsf.org/wiki/Vixie-cron

## The Big Picture ##

This section gives a brief summary of what each component does, and
does not if necessary.

1. **offlineimap**.  It does mainly two things:
   1. retrive mail from server to local folder, and
   2. sync flags on local mails to server.  For example, when you
      finish reading a mail in `gnus`, the mail is marked as *read*;
      `offlineimap` will sync this *read* flag to the server to make
      sure that the mail on the server is also marked as *read*.

  It does *NOT* do two things,
  1. send mails, which is done by `msmtp`;
  2. invoke itself, which is done by `cron`.
2. **msmtp**.  It sends mails.  It will be automatically invoked by
   `gnus` once both are properly configured.  You never need to
   manually start the program yourself.  Most of the time you are not
   even aware of its existence.
3. **dovecot**.  It serves mails.  `dovecot` is a simple yet powerful
   mail server.  Wait, why do we ever need a local server?
   `offlineimap` already downloads all the mails to local folders, and
   `gnus` *can* directly read local folders, why bother with another
   mail server?  Because `gnus` sometimes messes up the IMAP mails.
   `gnus` is known to have problems properly handling flags, e.g.,
   *read*, on mails.  Instead of using `gnus` to directly messing up
   with mail, we use a delicate mail server, `dovecot` to interact
   with mails professionally.  In this case,  `gnus` only tells
   `dovecot` what it wants to do and `dovecot` does it accordingly.
   For example, when finishing reading a mail in `gnus`, `gnus` sents
   notifies `dovecot` that this mail should be marked as *read*,
   `dovecot` does it accordingly.  And as you already know it, this
   *read* flag with be synced by `offlineimap`.
4. **cron**.  Invoke `offlineimap` periodically.  `offlineimap` does
   not run by itself magically, we need to invoke `offlineimap`
   periodically to sync between remote and local.  You may also invoke
   `offlineimap` manually if that's how want it LOL.
5. **gnus**.  You read/write/reply/... mails in it.  Basically it is a
   interface where you interact with mails.  Although `gnus` can
   actually finished all the above mentioned jobs by itself (woooof),
   I decide to use professional utilities to handle what it is best
   at.

## Devil Is in the Detail ##

This section explains in detail configuration of each component.  Note
that there are many possible working configurations available, what's
outlined here is just one of them (as a result of my years of
frustration).

### offlineimap ###

Full configuration in [offlineimaprc](./offlineimaprc).

The configuration is minimum yet fully functional.  Most of the
configuration are self-evident except for, perhaps, the `nametrans`.

According to the
official
[document on `nametrans`](http://www.offlineimap.org/doc/versions/v6.5.6/nametrans.html#nametrans),
it allows you to have different folder name other than the names on
the remote server.  For example, when login in Gmail, you will see
folders [1], e.g., `Sent Mail` for sent mails, `Trash` for deleted
mails, etc.  Different mail server may name these folders differently.
If you want a unified names locally, you can use `nametrans` features
to map a remote folder to the local folder with a different name,
e.g., `sent` for sent mails that syncs with `Sent Mail`, `trash` for
deleted mails that syncs with `Trash`, etc.

In my configuration, `nametrans` takes a Python function, with sole
parameter `folder`, i.e., the remote folder name in string.

`folderfilter` controls which folders to sync.  Please refer
to
[document on `folderfilter`](http://www.offlineimap.org/doc/versions/v6.5.6/nametrans.html#folderfilter) for
more details.

[1]: Actually *virtual folders*, since all mails in Gmail are stored in *All Mail* folder, other folder names are just *tags* despite that they are visually displayed as *folders*.

### mstp ###

Full configuration in [msmtprc](./msmtprc).

The configuration is just standard.  I copied the configuration from
online.

### dovecot ###

Full configuration [2] in [10-mail.conf](./10-mail.conf).

There is only one change made in `10-mail.conf` which usually resides
in `/etc/dovecot/conf.d/`.

[2]: Not *full* configuration actually, there are lots of configuration files for `dovecot`, most of which, however, work out of the box.

### cron ###

The cron jobs are listed in [cron-jobs](./cron-jobs).

Insert this cron job, the cron will invoke `offlineimap` periodically.

### gnus ###

Full configuration in [gnus-conf.el](./gnus-conf.el).

This is the most *frustrating* part.  I copied my full configuration
here just for your information.  However, the essential part that
makes it *just work* are detailed as follows.

#### Connects to `dovecot` ####

```emacs-lisp
(setq gnus-select-method
      '(nnimap "LocalMail"
               (nnimap-address "localhost")
               (nnimap-stream network)
               (nnimap-server-port 143)))
```

Remember that we have a local mail server, `dovecot`, running?  The
above code connects `gnus` to `dovecot`.  Whenever we/gnus want to
read mails, `gnus` notifies `dovecot` which retrieves mails from local
folder and send it to `gnus`.

#### Read mails ####

```emacs-lisp
(setq mail-user-agent 'gnus-user-agent)
(setq read-mail-command 'gnus)
```

The above code notifies `emacs` that we want to use `gnus` to handle
mails, since there are other options, e.g., `rmail`.

#### Sending mails ####

```emacs-lisp
(setq send-mail-function 'message-send-mail-with-sendmail)
(setq sendmail-program "msmtp")
```
The above code specifies that we want to use `msmtp` to send mails.
Basically when finish editing a mail in `gnus`, you hit <kbd>C-c
C-c</kbd>, the `gnus` automatically invoke `msmtp` to send mails.

#### Where to store sent mails ####

```emacs-lisp
(setq gnus-message-archive-group
      `(("Tiger" "nnimap+tiger:Tiger/sent")
        ("Gmail" "nnimap+gmail:Gmail/sent")
        (".*" ,(format-time-string "sent/%Y-%m"))))
```

The above code specifies where the sent mails are stored.  Note that
`Tiger/sent` is the actual folder where sent mails are stored.
Remember that we use `nametrans` to map remote folder to local folder
with a different name?  If you don't use `nametrans` feature, then
this `Tiger/sent` might be `Tiger/Sent Mails`, `Tiger/Sent Items` or
some other names.

#### Per email account configuration ####

```emacs-lisp
(setq gnus-parameters
      '(("Tiger.*"
         (charset . utf-8)
         (posting-style
          (address "zzg0009@auburn.edu")
          (gcc "nnimap+tiger:Tiger/sent")
          (name "Zhitao Gong")
          (signature-file "tiger")
          (organization "Auburn CSSE")))
        ("Gmail.*"
         (charset . utf-8)
         (posting-style
          (address "zhitaao.gong@gmail.com")
          (gcc "nnimap+gmail:Gmail/sent")
          (name "Zhitao Gong")
          (signature-file "gmail")
          (organization "Auburn University")))))
```

This above code configures each account separately, e.g, signatures,
charset, etc.

#### Miscellaneous ####

All other configurations are just for personal preference.  You could
easily find their document online or through `emacs` inline manual.

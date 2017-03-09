;;; gnus-conf.el
;;; Time-stamp: <2017-03-08 11:18:48 gongzhitaao>

(require 'gnus)
(require 'gnus-diary)

(setq user-full-name "Zhitao Gong")
(setq user-mail-address "me@gongzhitaao.org")

(setq gnus-select-method
      '(nnimap "LocalMail"
               (nnimap-address "localhost")
               (nnimap-stream network)
               (nnimap-server-port 143)))

(defun me//header-age-level (header)
  "Return the age of the header

The age are divided into three levels:
0: no more than one day old
1: no more than one week old
2: otherwise

Based on the age of the header, I set different foreground color
for the header string.
"
  (let* ((now (time-to-days (current-time)))
         (header-date-time (time-to-days (safe-date-to-time
                                          (mail-header-date header))))
         (mail-age (- now header-date-time)))
    (cond
     ((< mail-age 1) 0)
     ((< mail-age 7) 1)
     (t 2))))

(defface me--one-day-old
  '((default (:foreground "#ADFF2F" :slant normal :strike-through nil)))
  "...")
(defface me--one-week-old
  '((default (:foreground "#79B221" :slant normal :strike-through nil)))
  "...")
(defface me--more-than-one-week-old
  '((default (:foreground "#456613" :slant normal :strike-through nil)))
  "...")

(defun gnus-user-format-function-color-date (header)
  (let ((header-date-time-string
         (format-time-string
          "%Y-%m-%d %H:%M" (safe-date-to-time (mail-header-date header))))
        (age-level (me//header-age-level header)))
    (cond
     ((= 0 age-level)
      (propertize header-date-time-string
                  'face '(me--one-day-old default)
                  'gnus-face t))
     ((= 1 age-level)
      (propertize header-date-time-string
                  'face '(me--one-week-old default)
                  'gnus-face t))
     (t
      (propertize header-date-time-string
                  'face '(me--more-than-one-week-old default)
                  'gnus-face t)))))

(set-face-italic 'gnus-summary-normal-read nil)
(set-face-italic 'gnus-summary-normal-ancient nil)

(setq-default
 gnus-summary-line-format "%U%R%z%I %(%u&color-date;  %-30,30f  %B%s%)\n"
 gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
 gnus-thread-sort-functions '(gnus-thread-sort-by-most-recent-date))

(setq
 gnus-summary-to-prefix               "" ;[#xF061]
 gnus-summary-newsgroup-prefix        "" ;[#xF1EA]
 gnus-ancient-mark                    ? ;[#xF00C]
 gnus-ticked-mark                     ? ;[#xF024]
 gnus-dormant-mark                    ? ;[#xF11D]
 gnus-expirable-mark                  ? ;[#xF1B8]
 gnus-read-mark                       ? ;[#xF046]
 gnus-del-mark                        ? ;[#xF00D]
 gnus-canceled-mark                   ? ;[#xF00D]
 gnus-killed-mark                     ? ;[#xF00D]
 gnus-replied-mark                    ? ;[#xF112]
 gnus-forwarded-mark                  ? ;[#xF064]
 gnus-cached-mark                     ? ;[#xF0C5]
 gnus-recent-mark                     ? ;[#xF006]
 gnus-unseen-mark                     ? ;[#xF096]
 gnus-unread-mark                     ? ;[#xF003]
 gnus-score-over-mark                 ? ;[#xF148]
 gnus-score-below-mark                ? ;[#xF149]
 gnus-sum-thread-tree-false-root      " " ;[#xF10C]
 gnus-sum-thread-tree-single-indent   " " ;[#xF192]
 gnus-sum-thread-tree-indent          "  "
 gnus-sum-thread-tree-root            "  " ;[#xF111]
 gnus-sum-thread-tree-leaf-with-other " " ;[#xF178]
 gnus-sum-thread-tree-single-leaf     " " ;[#xF178]
 gnus-sum-thread-tree-vertical        "| ")

(setq gnus-gcc-mark-as-read t)
(setq gnus-face-properties-alist
      '((pbm . (:face gnus-x-face :ascent center))
        (png . (:ascent center))))
(setq gnus-treat-from-gravatar 'head)
(setq gnus-treat-mail-gravatar 'head)

(setq gnus-message-archive-group
      `(("Tiger" "nnimap+tiger:Tiger/sent")
        ("Gmail" "nnimap+gmail:Gmail/sent")
        (".*" ,(format-time-string "sent/%Y-%m"))))

(setq message-confirm-send t)

(setq message-signature-directory
      (expand-file-name "signature" me-emacs-data))

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
          (organization "Auburn University")))
        ;; ("Ymail.*"
        ;;  (charset . utf-8)
        ;;  (posting-style
        ;;   (address "gongzhitaao@yahoo.com")
        ;;   (name "Zhitao Gong")
        ;;   (signature-file "yahoo")
        ;;   (organization "Auburn University")))
        ))

(setq gnus-permanently-visible-groups
      (concat "^Tiger/\\(inbox\\|sent\\)\\'\\|"
              "^Gmail/\\(inbox\\|sent\\)\\'\\|"
              "^nndiary:Reminder\\'"))

(let ((my-mails (concat "\\(zhitaao\.gong@gmail\.com\\)\\|"
                        "\\(\\(zzg0009\\|gongzhitaao\\|zhitaao\\|gong\\)@\\(tigermail\.\\)?auburn\.edu\\)\\|"
                        "\\(me@gongzhitaao\.org\\)\\|"
                        "\\(gongzhitaao@yahoo\.com\\)")))
  (setq message-dont-reply-to-names my-mails))
(setq gnus-ignored-from-addresses (concat "\\(Zhitao\\( Gong\\)?\\)\\|"
                                          "\\(gongzhitaao\\)"))

(add-hook 'message-send-hook 'ispell-message)
(add-hook 'mail-send-hook  'ispell-message)

(gnus-demon-add-handler 'gnus-group-get-new-news 2 t)
(gnus-demon-init)

(setq gnus-list-groups-with-ticked-articles nil)

(add-hook 'gnus-after-getting-new-news-hook 'gnus-notifications)

(setq send-mail-function 'message-send-mail-with-sendmail)
(setq sendmail-program "msmtp")

(add-hook 'gnus-article-prepare-hook 'gnus-article-date-local)
(add-hook 'gnus-select-group-hook 'gnus-group-set-timestamp)

(setq message-forward-ignored-headers ""
      message-make-forward-subject-function 'message-forward-subject-fwd)

(add-to-list 'mm-discouraged-alternatives "text/html")
(add-to-list 'mm-discouraged-alternatives "image/.*")

(setq mail-user-agent 'gnus-user-agent)
(setq read-mail-command 'gnus)

(setq mm-inline-large-images nil)
(auto-image-file-mode t)
(setq mm-inline-text-html-with-images nil)

(setq message-forward-as-mime nil)
(setq message-forward-before-signature nil)

(add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)
(add-hook 'gnus-startup-hook 'bbdb-insinuate-message)
(add-hook 'message-mode-hook 'turn-on-orgstruct)
(add-hook 'message-mode-hook 'turn-on-orgstruct++)
(add-hook 'message-mode-hook 'turn-on-orgtbl)

(add-hook 'gnus-summary-mode-hook
          (lambda ()
            (hl-line-mode 1)))
(add-hook 'gnus-group-mode-hook
          (lambda ()
            (hl-line-mode 1)))

(when (display-graphic-p)

  (setq display-time-mail-function
        (lambda () ;; Gnus launched?
          (catch 'break
            (mapc
             (lambda (entry)
               (let ((group (car entry)))
                 (when (< (gnus-group-level group) 2)
                   (let ((unread (gnus-group-unread group)))
                     (if (and (numberp unread)
                              (> unread 0))
                         (throw 'break t))))))
             gnus-newsrc-alist)
            nil)))

  (setq display-time-mail-string " "
        display-time-use-mail-icon nil
        ;; display-time-mail-icon
        ;; `(image :type png
        ;;         :file ,(expand-file-name "mail-unread.png" my-icons-dir)
        ;;         :ascent center)
        ))

;;; gnus-conf.el ends here

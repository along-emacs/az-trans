;; -*- coding: utf-8 -*-
(require 'request)
(require 'pos-tip)
(require 'subr-x)
(require 'json)

(defvar *trans-key*
  "")

(defvar *trans-url*
  "https://api.cognitive.microsofttranslator.com/translate")

(defvar *trans-word* "")

(defvar *trans-hist* nil)		;TODO: show list of history

(defun az-trans-get-words ()
  (let* ((raw (if (use-region-p)
		  (buffer-substring-no-properties
		   (region-beginning) (region-end))
		(or (thing-at-point 'word     t)
		    (thing-at-point 'sentence t)
		    (thing-at-point 'line     t))))
	 (str1 (replace-regexp-in-string " +" " " raw))
	 (str2 (replace-regexp-in-string "\n" "" str1))
	 (last (string-trim str2)))
    (setq *trans-word* last)))

(defun az-trans ()
  "invoke translate API of Azure."
  (interactive)
  (az-trans-get-words)
  (if (string-empty-p *trans-word*)
      (message "No word/sentence/line at point!")
    (progn (request *trans-url*
		    :type "POST"
		    :timeout 5
		    :parser 'json-read
		    :params '(("api-version" . "3.0")
			      ("from" . "en-us") ("to" . "zh-Hans"))
		    :headers `(("Ocp-Apim-Subscription-Key" . ,*trans-key*)
			       ("Content-Type" . "application/json"))
		    :data (json-encode `((("text" . ,*trans-word*))))
		    :success (cl-function
			      (lambda (&key data &allow-other-keys)
				(let* ((text (alist-get 'text (elt (alist-get 'translations (elt data 0)) 0)))
				       (msg (format "%s => %s" *trans-word* text)))
				  ;; (pos-tip-show-no-propertize msg)
				  (message msg))))
		    :error (cl-function (lambda (&key data &allow-other-keys) (message "Something wrong..."))))
	   (let ((msg (format "%s => ..." *trans-word*)))
	     ;; (pos-tip-show-no-propertize msg)
	     (message msg)))))

(global-set-key (kbd "C-`") 'az-trans)
(provide 'az-trans)

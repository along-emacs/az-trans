(eval-when-compile
  (require 'cl))

(require 'pos-tip)

(defvar az-trans-process-name
  "aztranprocess"
  "process name")

(defvar az-trans-buffer-name
  (concat az-trans-process-name
	  "-buffer")
  "buffer name")

(defvar az-trans-powershell
  (concat (getenv "systemroot")
	  "\\system32\\WindowsPowerShell\\v1.0\\powershell.exe")
  "powershell.exe full path")

(defvar az-trans-ps1
  "d:\\tmp\\az-trans.ps1"
  "az-trans.ps1 path")

(defvar az-trans-key
  "aa54607b79804e06814b289ca35c268d"
  "key to call Azure cognitive translating service API")

(defvar az-trans-from
  "en"
  "lang code: from")

(defvar az-trans-to
  "zh-Hans"
  "lang code: to")

(defvar az-trans-word
  ""
  "")

(defun az-trans-show-point-word ()
  (interactive)
  (let ((az-trans-word (concat ""
			       (word-at-point))))
    (set-process-sentinel
     (start-process az-trans-process-name
		    az-trans-buffer-name
		    az-trans-powershell
		    "-NoProfile"
		    "-File" az-trans-ps1
		    "-key"  az-trans-key
		    "-from" az-trans-from
		    "-to"   az-trans-to
		    "-word" az-trans-word)
     (lambda (process event)
       (cond ((equal event "finished\n")
	      (pos-tip-show
	       (with-current-buffer az-trans-buffer-name
		 (prog1  (buffer-string)
		   (kill-buffer)))))
	     (t nil))))
    (pos-tip-show (concat az-trans-word
			  "\n..."))))

;;;###autoload
(define-minor-mode az-trans-mode
  "Translate by using Azure Service"
  :lighter " az-trans"
  :keymap (let ((map (make-sparse-keymap)))
	    (define-key map
	      (kbd "C-c d") 'az-trans-show-point-word)
	    map))

(provide 'az-trans-mode)

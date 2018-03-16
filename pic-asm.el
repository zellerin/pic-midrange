;;; pic-asm.el --- Assembler for Pic midrange microchips  -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Tomas Zellerin

;; Author: Tomas Zellerin <tomas@zellerin.cz>
;; Keywords: languages, local
;; Version: 0.1
;; Package-requires: ((emacs "24"))
;; Url: https://github.com/zellerin/pic-midrange/

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Provide
;;   - Fontification
;;   - compile key binding
;;   - auto-insert template
;; for pic midrange assembler.

;;; Code:

;; tz-pic.el --- Fontification for Microchip midrange assembler

(defvar pic-asm-instruction-words
  (regexp-opt
   '("movwf" "movlw"
     "clrf" "goto"
     "call"
     "addlw" "andlw" "iorlw"
     "equ" "res")
   'words))

(defvar pic-asm-instruction-words-wf
  (regexp-opt
   '("movf"  "swapf"
     "incf" "decf"
     "subwf"
     "rlf" "rrf"  "iorlw" "decfsz")
   'words))

(defvar pic-asm-instruction-noop-words
  (regexp-opt
   '( "retfie" "sleep" "return" "retfie" "wdtrst")
   'words))

(defvar pic-asm-vanilla-builtins
  (regexp-opt
   '("udata_shr" "code" "end" "title" "include")
   'words)  )

(defvar pic-asm-instruction-bit-words
  (regexp-opt
   '("bsf" "bcf" "btfsc" "btfss")
   'words))

(defvar pic-asm-var-words
  (regexp-opt
   '("PORTA" "PORTC" "TRISA" "TRISC" "STATUS"
     "CMCON" "TMR1H" "TMR1L" "T1CON"
     "EEADR" "EECON1" "EEDAT" "FSR" "INDF")
   'words))

(defvar pic-asm-var-bits
    (regexp-opt
     '("STATUS, C" "STATUS, Z" "STATUS, RP0"
       "PORTA, RS")
   'words))

(defvar pic-asm-constants
  (concat "\\<0x[0-9a-fA-F]+\\>\\|\\<[0-9]+\\>\\|"
	  (regexp-opt
	   '("_INTRC_OSC_NOCLKOUT"
	     "_WDT_ON"))))

(defcustom pic-asm-processor "16f630"
  "Default processor for auto insert skeleton."
  :group 'pic-asm)

;;;###autoload
(define-skeleton pic-asm-new-file
  "Insert assembler skeleton file"
  "Title: "
  (pic-asm-mode)
  ";; -*- mode:pic-asm; coding: utf-8 -*-" ?\n
  "\tlist p=" (upcase pic-asm-processor) ?\n
  "\ttitle \"" str "\"" ?\n
  "\tradix DEC" ?\n
  "\tinclude \"p" pic-asm-processor ".inc\"" ?\n ?\n
  ("equ label: " str "\tequ " (read-string "Value: ") ?\n)
  ?\n
  "\tudata_shr" ?\n
  ("Variable: " str "\tres " (read-string "Size: " "1") ?\n) ?\n
  "\tcode" ?\n ?\t _ ?\n ?\n
  "DEEPROM\tcode" ?\n
  ";\tde 0" ?\n ?\n

  "\tend" ?\n
)

(defun pic-asm-fontify ()
  "Fontify document based on pic-asm conventions."
  (setq font-lock-defaults
	`(((;; No op, just label
	    "^[^:\n[:space:]]+:?" (0 font-lock-variable-name-face))
	   ;; no op instruction
	   (,pic-asm-instruction-noop-words (0 font-lock-function-name-face))
	   ;; builtins with no special handling
	   (,pic-asm-vanilla-builtins (0 font-lock-builtin-face))
	   ;; one op instructions
	   (,pic-asm-instruction-words (0 font-lock-function-name-face)
	    (,pic-asm-var-words nil nil
			 (0 font-lock-constant-face))
	    (",.*" nil nil (0 font-lock-warning-face))
	    ("\\<[[:alpha:]_][[:alnum:]_]+\\>" nil nil (0 font-lock-variable-name-face))
	    (,pic-asm-constants nil nil
			 (0 font-lock-constant-face)))
	   ("radix" (0 font-lock-builtin-face)
	    (,(regexp-opt '("DEC" "HEX") 'words)
	     nil nil (0 font-lock-constant-face)))
	   ("list" (0 font-lock-builtin-face)
	    ("\\<[pntc]=[[:alnum:]]+" nil nil (0 font-lock-constant-face)))
	   (,(regexp-opt '("global" "extern" "de" "dw") 'words)
	    (0 font-lock-builtin-face)
	    ("\\<[_[:alnum:]]+" nil nil
	     (0 font-lock-variable-name-face)))
	   ;; with direction
	   (,pic-asm-instruction-words-wf
	    (0 font-lock-function-name-face)
	    (,(concat pic-asm-var-words ", [WFwf]") nil nil
				(0 font-lock-constant-face))
	    (,pic-asm-constants nil nil
			 (0 font-lock-constant-face))
	    ("[_[:alpha:]][[:alnum:]_]+" nil nil (0 font-lock-variable-name-face))
	    (", \\<[wfWF]\\>"
	     nil nil (0 font-lock-builtin-face)))
	   ;; bit ops
	   (,pic-asm-instruction-bit-words
	    (0 font-lock-function-name-face)
	    (,pic-asm-var-bits nil nil
			(0 font-lock-constant-face))
	    (,(concat pic-asm-var-words ",") nil nil
			 (0 font-lock-constant-face))
	    ("[_[:alpha:]][[:alnum:]_]+" nil nil (0 font-lock-variable-name-face))
	    (,pic-asm-constants nil nil
			 (0 font-lock-constant-face)))))))

;;;###autoload
(define-derived-mode pic-asm-mode asm-mode "Pic asm"
  (pic-asm-fontify)
  (set (make-local-variable 'compile-command)
       (concat "gpasm -c "
	       (if buffer-file-name
		   (shell-quote-argument
		    buffer-file-name))))
  (setq ff-other-file-alist '((".asm" (".inc")))
	ff-search-directories '("." "/usr/share/gputils/header")
	ff-special-constructs '(("\\s *include\\s \"\\([^\"]*\\)" .
				  (lambda () (buffer-substring (match-beginning 1)
							       (match-end 1)))))))

(bind-key (kbd "C-c C-c") 'compile pic-asm-mode-map)


(provide 'pic-asm)
;;; pic-asm.el ends here

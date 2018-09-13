;;; pic-asm.el --- Assembler for Pic midrange microchips  -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Tomas Zellerin

;; Author: Tomas Zellerin <tomas@zellerin.cz>
;; Keywords: languages, local
;; Version: 0.2
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
     "addlw" "andlw" "iorlw")
   'words))

(defvar pic-asm-directives
  (regexp-opt
   '("equ" "res" "org")
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
   '( "retfie" "sleep" "return" "retfie" "clrwdt")
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
  (concat "\\<0x[0-9a-fA-F]+\\>\\|\\<[0-9]+\\>\\"))

; See [[file:/usr/share/gputils/header/p12f675.inc::%20CONFIG%20Options][CONFIG]]
(defvar pic-asm-config-words
  (regexp-opt
   '("_INTRC_OSC_NOCLKOUT" "_INTRC_OSC_CLKOUT"
     "_EXTRC_OSC_NOCLKOUT" "_EXTRC_OSC_CLKOUT"
     "_LP_OSC" "_XT_OSC" "_HS_OSC" "_EC_OSC"
     "_WDT_ON" "_WDT_OFF"
     "_MCLRE_ON" "_MCLRE_OFF"
     "_CP_ON" "_CP_OFF" "_CPD_ON" "_CPD_OFF")))

(defcustom pic-asm-processor "16f630"
  "Default processor for auto insert skeleton."
  :group 'pic-asm)

;;;###autoload
(define-skeleton pic-asm-new-file
  "Insert assembler skeleton file"
  "Title: "
  (pic-asm-mode)
  ";; -*- mode:pic-asm; coding: utf-8 -*-" ?\n
  "\tinclude \"config.h\" " ?\n ?\n
  "\ttitle \"" str "\"" ?\n
  "\tradix DEC" ?\n
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
	   (,pic-asm-directives (0 font-lock-builtin-face)
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
	   ("__config" (0 font-lock-builtin-face)
	    (,(concat "[(& ]\\(" pic-asm-config-words "\\)\\>") nil nil (1 font-lock-constant-face))
	    ("[_[:alnum:]]+" nil nil (0 font-lock-warning-face) ))
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

(defcustom pic-asm-compile "gpasm -c"
  "Command to run to compile by default. File name is added.")

;;;###autoload
(define-derived-mode pic-asm-mode asm-mode "Pic asm"
  (pic-asm-fontify)
  (set (make-local-variable 'compile-command)
       (concat pic-asm-compile " "
	       (if buffer-file-name
		   (shell-quote-argument
		    buffer-file-name))))
  (setq ff-other-file-alist '((".asm" (".inc")))
	ff-search-directories '("." "/usr/share/gputils/header")
	ff-special-constructs '(("\\s *include\\s \"\\([^\"]*\\)" .
				  (lambda () (buffer-substring (match-beginning 1)
							       (match-end 1)))))))

(defun pic-asm-simulate ()
  (interactive)
  (switch-to-buffer
   (make-comint "Simulate" "make" nil "sim"))
  (gpsim-stc-mode))

(bind-key "C-c C-c" 'compile pic-asm-mode-map)
(bind-key "C-c C-s" 'pic-asm-simulate pic-asm-mode-map)


(provide 'pic-asm)
;;; pic-asm.el ends here

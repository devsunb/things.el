;;; things-test.el --- Tests for things.el -*- lexical-binding: t; -*-

;;; Commentary:
;; Run with:
;;   emacs --batch -L . -l things-test.el -f ert-run-tests-batch-and-exit

;;; Code:

(require 'ert)
(require 'things)

(defmacro things-test-with-text (text &rest body)
  "Run BODY in an `emacs-lisp-mode' buffer of TEXT.
Point starts where TEXT has a |, which is removed."
  (declare (indent 1))
  `(with-temp-buffer
     (emacs-lisp-mode)
     (insert ,text)
     (goto-char (point-min))
     (search-forward "|")
     (delete-char -1)
     ,@body))

(ert-deftest things-test-forward-string ()
  "A positive count moves to the end of the next string."
  (things-test-with-text "(a |\"one\" b \"two\" c)"
    (should (= (things-forward 'things-string 1) 9))
    (should (= (things-forward 'things-string 1) 17))))

(ert-deftest things-test-backward-string ()
  "A negative count moves to the beginning of the previous string.
It used to run its body no times and move forward when it did."
  (things-test-with-text "(a \"one\" b \"two\" c|)"
    (should (= (things-forward 'things-string -1) 12))
    (should (= (things-backward 'things-string) 4))))

(ert-deftest things-test-backward-count ()
  "A negative count of 2 moves back two strings."
  (things-test-with-text "(a \"one\" b \"two\" c|)"
    (should (= (things-forward 'things-string -2) 4))))

(ert-deftest things-test-backward-none ()
  "Without a previous string, nothing moves and nil is returned."
  (things-test-with-text "(a |\"one\")"
    (should-not (things-backward 'things-string))
    (should (= (point) 4))))

(provide 'things-test)
;;; things-test.el ends here

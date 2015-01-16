;;; xinix-packages.el --- Emacs Xinix: default package selection.
;;
;; Copyright © 2011-2014 Bozhidar Batsov
;;
;; Author: Bozhidar Batsov <bozhidar@batsov.com>
;; URL: https://github.com/bbatsov/xinix
;; Version: 1.0.0
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Takes care of the automatic installation of all the packages required by
;; Emacs Xinix.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:
(require 'cl)
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
;; set package-user-dir to be relative to Xinix install path
(setq package-user-dir (expand-file-name "elpa" xinix-dir))
(package-initialize)

(defvar xinix-packages
  '(ace-jump-mode
    ace-jump-buffer
    ace-window
    anzu
    browse-kill-ring
    dash
    discover-my-major
    diff-hl
    diminish
    easy-kill
    elisp-slime-nav
    epl
    expand-region
    flycheck
    gist
    git-timemachine
    gitconfig-mode
    gitignore-mode
    god-mode
    grizzl
    guru-mode
    ov
    projectile
    magit
    move-text
    operate-on-number
    rainbow-mode
    smartparens
    smartrep
    undo-tree
    volatile-highlights
    zenburn-theme
    solarized-theme)
  "A list of packages to ensure are installed at launch.")

(defun xinix-packages-installed-p ()
  "Check if all packages in `xinix-packages' are installed."
  (every #'package-installed-p xinix-packages))

(defun xinix-require-package (package)
  "Install PACKAGE unless already installed."
  (unless (memq package xinix-packages)
    (add-to-list 'xinix-packages package))
  (unless (package-installed-p package)
    (package-install package)))

(defun xinix-require-packages (packages)
  "Ensure PACKAGES are installed.
Missing packages are installed automatically."
  (mapc #'xinix-require-package packages))

(define-obsolete-function-alias 'xinix-ensure-module-deps 'xinix-require-packages)

(defun xinix-install-packages ()
  "Install all packages listed in `xinix-packages'."
  (unless (xinix-packages-installed-p)
    ;; check for new packages (package versions)
    (message "%s" "Emacs Xinix is now refreshing its package database...")
    (package-refresh-contents)
    (message "%s" " done.")
    ;; install the missing packages
    (xinix-require-packages xinix-packages)))

;; run package installation
(xinix-install-packages)

(defun xinix-list-foreign-packages ()
  "Browse third-party packages not bundled with Xinix.

Behaves similarly to `package-list-packages', but shows only the packages that
are installed and are not in `xinix-packages'.  Useful for
removing unwanted packages."
  (interactive)
  (package-show-package-list
   (set-difference package-activated-list xinix-packages)))

(defmacro xinix-auto-install (extension package mode)
  "When file with EXTENSION is opened triggers auto-install of PACKAGE.
PACKAGE is installed only if not already present.  The file is opened in MODE."
  `(add-to-list 'auto-mode-alist
                `(,extension . (lambda ()
                                 (unless (package-installed-p ',package)
                                   (package-install ',package))
                                 (,mode)))))

(defvar xinix-auto-install-alist
  '(("\\.clj\\'" clojure-mode clojure-mode)
    ("\\.coffee\\'" coffee-mode coffee-mode)
    ("\\.css\\'" css-mode css-mode)
    ("\\.csv\\'" csv-mode csv-mode)
    ("\\.d\\'" d-mode d-mode)
    ("\\.dart\\'" dart-mode dart-mode)
    ("\\.ex\\'" elixir-mode elixir-mode)
    ("\\.exs\\'" elixir-mode elixir-mode)
    ("\\.elixir\\'" elixir-mode elixir-mode)
    ("\\.erl\\'" erlang erlang-mode)
    ("\\.feature\\'" feature-mode feature-mode)
    ("\\.go\\'" go-mode go-mode)
    ("\\.groovy\\'" groovy-mode groovy-mode)
    ("\\.haml\\'" haml-mode haml-mode)
    ("\\.hs\\'" haskell-mode haskell-mode)
    ("\\.kv\\'" kivy-mode kivy-mode)
    ("\\.latex\\'" auctex LaTeX-mode)
    ("\\.less\\'" less-css-mode less-css-mode)
    ("\\.lua\\'" lua-mode lua-mode)
    ("\\.markdown\\'" markdown-mode markdown-mode)
    ("\\.md\\'" markdown-mode markdown-mode)
    ("\\.ml\\'" tuareg tuareg-mode)
    ("\\.pp\\'" puppet-mode puppet-mode)
    ("\\.php\\'" php-mode php-mode)
    ("\\.proto\\'" protobuf-mode protobuf-mode)
    ("PKGBUILD\\'" pkgbuild-mode pkgbuild-mode)
    ("\\.rs\\'" rust-mode rust-mode)
    ("\\.sass\\'" sass-mode sass-mode)
    ("\\.scala\\'" scala-mode2 scala-mode)
    ("\\.scss\\'" scss-mode scss-mode)
    ("\\.slim\\'" slim-mode slim-mode)
    ("\\.swift\\'" swift-mode swift-mode)
    ("\\.textile\\'" textile-mode textile-mode)
    ("\\.thrift\\'" thrift thrift-mode)
    ("\\.yml\\'" yaml-mode yaml-mode)
    ("\\.yaml\\'" yaml-mode yaml-mode)
    ("Dockerfile\\'" dockerfile-mode dockerfile-mode)))

;; markdown-mode doesn't have autoloads for the auto-mode-alist
;; so we add them manually if it's already installed
(when (package-installed-p 'markdown-mode)
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)))

(when (package-installed-p 'pkgbuild-mode)
  (add-to-list 'auto-mode-alist '("PKGBUILD\\'" . pkgbuild-mode)))

;; build auto-install mappings
(mapc
 (lambda (entry)
   (let ((extension (car entry))
         (package (cadr entry))
         (mode (cadr (cdr entry))))
     (unless (package-installed-p package)
       (xinix-auto-install extension package mode))))
 xinix-auto-install-alist)

(provide 'xinix-packages)
;; Local Variables:
;; byte-compile-warnings: (not cl-functions)
;; End:

;;; xinix-packages.el ends here
; gist doesn't know what fennel is so let's say clj
; vi: ft=clojure
(set hs.logger.defaultLogLevel "info")
(local {:application app :hotkey hotkey} hs)

; use the SpoonInstall Spoon easy installing+loading of Spoons
(hs.loadSpoon :SpoonInstall)
(local install (. spoon :SpoonInstall))

; for window sizing, use the WIndowHalfsAndThirds Spoon until I can write something custom
;; (: install :andUse :WindowHalfsAndThirds)

; just bind the default hotkeys for now
;; (: spoon.WindowHalfsAndThirds :bindHotkeys
;;    (. spoon :WindowHalfsAndThirds :defaultHotkeys))


;; fennel = require("fennel")
;; (local zoomWindow (hs.window.find "Zoom"))
;; (when zoomWindow
;;   (local zoomApp (. zoomWindow :application))
;;   (local zoomAXApp (hs.axuielement.applicationElement zoomApp))

;;   (fn searchCallback [element]
;;     (and (= (. element :attributeValue "AXSubrole") "AXOutline")
;;          (= (. element :attributeValue "AXRole") "AXTable")))

;;   (local attendeesList (. zoomAXApp :elementSearch searchCallback))
;;   (when attendeesList
;;     (each [i attendee (ipairs (. attendeesList :children))]
;;       (local name (. attendee :attributeValue "AXTitle"))
;;       (print name))))

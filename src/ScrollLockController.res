type t = {
  locks: ScrollLockController_Helpers.LocksSet.t,
  isLocked: ScrollLockController_Helpers.TrackedValue.t<bool>,
}

let make = (~onBodyScrollLock=?, ~onBodyScrollUnlock=?, ()) => {
  let locks = ScrollLockController_Helpers.LocksSet.make()

  let isLocked = ScrollLockController_Helpers.TrackedValue.make(~onChage=newIsLocked => {
    switch (newIsLocked, onBodyScrollLock, onBodyScrollUnlock) {
    | (true, Some(onBodyScrollLockCb), _) => onBodyScrollLockCb()
    | (false, _, Some(onBodyScrollUnlockCb)) => onBodyScrollUnlockCb()
    | (_, _, _) => ()
    }
  }, ~defaultValue=false)

  {
    locks: locks,
    isLocked: isLocked,
  }
}

let isBodyScrollLocked = (it: t) => {
  !(it.locks->ScrollLockController_Helpers.LocksSet.isEmpty)
}

let lock = (it: t, targetElements) => {
  let added = it.locks->ScrollLockController_Helpers.LocksSet.add(targetElements)

  added->Js.Array2.forEach(targetElement => {
    BodyScrollLock.disableBodyScroll(
      targetElement,
      ~options=BodyScrollLock.bodyScrollOptions(~reserveScrollBarGap=true, ()),
      (),
    )
  })

  it.isLocked->ScrollLockController_Helpers.TrackedValue.set((. _) => it->isBodyScrollLocked)
}

let unlock = (it: t, targetElements) => {
  let removed = it.locks->ScrollLockController_Helpers.LocksSet.remove(targetElements)

  removed->Js.Array2.forEach(targetElement => {
    BodyScrollLock.enableBodyScroll(targetElement)
  })

  it.isLocked->ScrollLockController_Helpers.TrackedValue.set((. _) => it->isBodyScrollLocked)
}

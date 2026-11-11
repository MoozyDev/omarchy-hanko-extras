// Only one copy of the widget works: the bar loads one per screen without
// telling them which screen they are on. A ".pragma library" is shared by
// every copy: the first one to claim it keeps it.
.pragma library

var owner = null

function claim(item) {
  if (owner === null) owner = item
  return owner === item
}

function release(item) {
  if (owner === item) owner = null
}

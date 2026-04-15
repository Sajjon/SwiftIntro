# 📱 My first Memory 🤔💭
#### _An introduction to iOS development with Swift._

A memory game implementation fetching images from Wikimedia. This project aims to introduce you to iOS development with Swift disregarding of your current skill level.

> **Architecture & design decisions:** [DESIGN.md](DESIGN.md)
> **AI assistant instructions:** [CLAUDE.md](CLAUDE.md)

# Challenges
## Modernize UIKit
### State driven
We should use state driven UIKit elements

### Multi-window
Lets add an iPad only feature, where we can see the cards we have already matched, in another window.

## Swift techniques
Split immutable values from mutable ones in GameModel and use @dynamicMemberLookup to make this virtually identical to what we had.

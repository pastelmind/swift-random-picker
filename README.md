# swift-random-picker

This is a Swift port of my Go program, [Gorup](https://github.com/pastelmind/gorup). It randomly picks an item from a list.

## Examples

```
swift-random-picker sausage steak hamburger
```

Pick an item between `sausage`, `steak`, and `hamburger` with equal probability.

```
swift-random-picker sausage -q1.1 steak -q 3 hamburger jerky
```

Pick an item between `sausage`, `steak`, `hamburger`, and `jerky`, with weighted probability of 1 : 1.1 : 3 : 1.

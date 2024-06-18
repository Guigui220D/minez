# Block JSONs

## Intro

These json files are meant to be used at comptime to generate the block register. It is especially useful for the WFC weights.

## Fields

### Name

This field is a string and is necessary. It is a unique identifier and its recommended that it is the name of the file.

### Dig time

This field is a float and is the time it takes to break at the base strength, in seconds. For instance, stone has 0.5.

TODO: allow values to indicate transparency or unbreakable

### Texture

This field is a string and is the name of the texture used for the block.

### WFC

This field is an ojbect describing weights for neighbors in the WFC generation.

It has objects for each spatial relationship: "any", "sides", "bottom", "top", and "diagonal" (TODO: decide this);

Each of these sub-fields is optional and contains, optionally, these fields:

- "forbidden": a list of block names that can't be neighbors in this group (the weight will be set for 0) (that one is just for readability)
- "weights": an object mapping block names to a weight. The default is 1 if a block is not mentionned and not in "forbidden"
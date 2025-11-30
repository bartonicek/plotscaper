# Get a plot scale

This function returns a specific scale from a specifc plot in a
`plotscaper` scene.

## Usage

``` r
get_scale(x, id = NULL, scale = NULL)
```

## Arguments

- x:

  A `plotscaper` scene

- id:

  A string id of the plot. See
  [id](https://bartonicek.github.io/plotscaper/reference/id.md)

- scale:

  A string id of the scale (`x`, `y`, `width`, `height`, `area`, or
  `size`)

## Value

A list of scale properties

## Details

This function is primarily meant for internal use, however, you can use
it to learn how `plotscaper` implements scales. The output can look a
bit overwhelming, however, it's not too complicated once you understand
how `plotscaper` scales work.

Each scale has two important properties:

- Domain: The space values are translated *from*

- Codomain: The space values are translated *to*

For example, in a typical scatterplot, the `x` scale might have the
range of the data (e.g. `[1, 10]`) as its domain and the width of the
plotting region as its codomain (e.g. `[0, 800]` pixels).

The scale's job is to link the domain and codomain, such that we can
*push* values forward through the scale, first through the domain and
then the codomain. This is done by translating to an intermediate range
`[0, 1]`. For example, using the `x` scale above, we might first
translate the value `5.5` to `0.5` (midpoint of the domain) and then
translate `0.5` to `400` (midpoint of the codomain). We may also be able
to reverse the process and *pull* values back through the scale, first
through the codomain and then through the domain.

Scale, domain, and codomain each have `props` and `defaults` properties
which store the relevant values. For example, for a continuous scale,
`props` and `defaults` store the `min` and `max` as well as a
transformation function and its inverse (`trans`, `inv`), for a discrete
point scale, they store the vector of labels, their order, etc...

On `scale`, the `props` and `defaults` store the following properties:
`zero`, `one`, `scale`, `mult`. The `zero` and `one` properties modify
where the normalized domain values get placed in the codomain, and vice
versa. Suppose our `x` (`[1, 10]`, `[0, 800]` px) scale had `zero = 0.1`
and `one = 0.9`. Then data values get pushed to the following
intermediate values:

- The value `1` to `0.1` since
  `0.1 + (1 - 1) / (10 - 1) * (0.9 - 0.1) = 0.1`

- The value `2` to `0.1889` since
  `0.1 + (2 - 1) / (10 - 1) * (0.9 - 0.1) = 0.1889`

- The value `3` to `0.2778` since
  `0.1 + ((3 - 1) / (10 - 1)) * (0.9 - 0.1) = 0.2778`

- ...

- The value `10` to `0.9` since
  `0.1 + ((10 - 1) / (10 - 1)) * (0.9 - 0.1) = 0.9`

When those values get translated to the space of the codomain, we end up
with 10% margins on each side, i.e.

- The value `1` gets pushed to `80` pixels

- ...

- The value `10` gets pushed to `720` pixels

The `scale` and `mult` properties both multiply the normalized domain
values. They work the same way, however, they are different
semantically: `scale` is meant to be constant whereas `mult` may change
dynamically, through interaction. For example, by default, in a barplot,
the `width` scale gets assigned the `scale` value of `1 / k`, where `k`
is the number of categories/bars, and a `mult` value of 0.9. This means
that each bar is `1 / k * 0.9 * [plot width in pixels]` wide, and we can
dynamically make it wider or narrower by pressing the `+/-` keys to
modify the `mult` property (but not the `scale` property).

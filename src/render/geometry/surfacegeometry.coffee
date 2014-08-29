Geometry = require './geometry'

###
Grid Surface

+----+----+----+----+
|    |    |    |    |
+----+----+----+----+
|    |    |    |    |
+----+----+----+----+

+----+----+----+----+
|    |    |    |    |
+----+----+----+----+
|    |    |    |    |
+----+----+----+----+
###

class SurfaceGeometry extends Geometry

  constructor: (options) ->
    super options

    @geometryClip = new THREE.Vector4

    @uniforms ?= {}
    @uniforms.geometryClip =
      type: 'v4'
      value: @geometryClip

    @width    = width    = +options.width    || 2
    @height   = height   = +options.height   || 2
    @surfaces = surfaces = +options.surfaces || 1
    @layers   = layers   = +options.layers   || 1

    @segmentsX = segmentsX = width  - 1
    @segmentsY = segmentsY = height - 1

    points    = width     * height    * surfaces * layers
    quads     = segmentsX * segmentsY * surfaces * layers
    triangles = quads * 2

    @addAttribute 'index',     new THREE.BufferAttribute new  Uint16Array(triangles * 3), 1
    @addAttribute 'position4', new THREE.BufferAttribute new Float32Array(points * 4),    4
    @addAttribute 'surface',   new THREE.BufferAttribute new Float32Array(points * 2),    2

    @_autochunk()

    index    = @_emitter 'index'
    position = @_emitter 'position4'
    surface  = @_emitter 'surface'

    base = 0
    for i in [0...surfaces * layers]
      for j in [0...segmentsY]
        for k in [0...segmentsX]
          index base
          index base + 1
          index base + width

          index base + width
          index base + 1
          index base + width + 1

          base++
        base++
      base += width

    for l in [0...layers]
      for z in [0...surfaces]
        for y in [0...height]
          edgeY = if y == 0 then -1 else if y == segmentsY then 1 else 0

          for x in [0...width]
            edgeX = if x == 0 then -1 else if x == segmentsX then 1 else 0

            position x, y, z, l

            surface edgeX, edgeY

    @_finalize()
    @clip()

    return

  clip: (width = @width, height = @height, surfaces = @surfaces, layers = @layers) ->

    segmentsX = Math.max 0, width  - 1
    segmentsY = Math.max 0, height - 1

    @geometryClip.set segmentsX, segmentsY, surfaces, layers

    dims  = [ layers,  surfaces,  segmentsY,  segmentsX]
    maxs  = [@layers, @surfaces, @segmentsY, @segmentsX]
    quads = @_reduce dims, maxs

    @_offsets [
      start: 0
      count: quads * 6
    ]

module.exports = SurfaceGeometry
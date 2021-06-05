- Particle size
- Number of particles
- Color
- End animation (Instant, Fade out)
- Particle types (Fire, Explode)
- Spread behavior (One Time, Continuous)
- Min/Max speed
- Time to live (ms)
- Has center base object
- Added blend mode option



```
// smoke
painter: ParticleEmitter(
                              listenable: _controller,
                              controller: _controller,
                              particleSize: Size(50, 50),
                              minParticles: 200,
                              center: Offset.zero,
                              color: _color,
                              radius: 2,
                              type: ShapeType.Circle,
                              endAnimation: EndAnimation.FADE_OUT,
                              particleType: ParticleType.EXPLODE,
                              spreadBehaviour: SpreadBehaviour.CONTINUOUS,
                              minimumSpeed: 0.3,
                              maximumSpeed: 0.5,
                              timeToLive: {"min": 200, "max": 800},
                              hasBase: false,
                              blendMode: BlendMode.lighten))))
```

// fire
```
 painter: ParticleEmitter(
                              listenable: _controller,
                              controller: _controller,
                              particleSize: Size(50, 50),
                              minParticles: 30,
                              center: Offset.zero,
                              color: _color,
                              radius: 10,
                              type: ShapeType.Circle,
                              endAnimation: EndAnimation.FADE_OUT,
                              particleType: ParticleType.FIRE,
                              spreadBehaviour: SpreadBehaviour.CONTINUOUS,
                              minimumSpeed: 0.01,
                              maximumSpeed: 0.1,
                              timeToLive: {"min": 10, "max": 15},
                              hasBase: true,
                              blendMode: BlendMode.srcOver,
                              delay: 5))))
```
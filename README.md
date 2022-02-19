# Shader Library
A collection of shaders for various use cases.

## Glitter Shader
This glitter shader tries to be smooth and juicy at the same time. Instead of manipulating the surface normals via a microfacet normal noise it manipulates the reflection vector using a random noise.

[<img alt="Glitter Comparison" width="300px" src="https://user-images.githubusercontent.com/65419234/154782120-dd77246e-0b24-46ad-b8a3-52b83b38a93a.gif" />](https://youtu.be/shqADz0JUE8)
[<img alt="Glitter Rotation" width="300px" src="https://user-images.githubusercontent.com/65419234/154782123-80917060-61f2-4dd8-80b7-fabf3cbd628b.gif" />](https://youtu.be/I0TwkiMZbl8)

## Focus Shader
This focus shader is useful for only showing specific areas of a map (for example like in Luigi's Mansion). The visibility transitions smoothly using a bluenoise texture.

[<img alt="Focus" width="300px" src="https://user-images.githubusercontent.com/65419234/154782128-dc814267-3b24-47d2-897e-ed47e971cac9.gif" />](https://youtu.be/OEqHJk0Lv5g)

## Rewind Shader
This rewind shader mimics the visual effect of a vhs rewinding or fast-forwarding. It comes with several settings and can be linked to the Time.timeScale.

[<img alt="Rewind" width="300px" src="https://user-images.githubusercontent.com/65419234/154782126-6c69b91f-c1f9-4625-8b33-4897a06be4d3.gif" />](https://youtu.be/XDoKmx6BQ3k)

## Screen Warp Shader
This shader renders a specific texture or the grab texture bend along the normals.

//
//  OpenGLView.swift
//  OpenglTest
//
//  Created by Carl on 1/7/2017.
//  Copyright © 2017 ricebook. All rights reserved.
//

import UIKit
import OpenGLES

struct Vertex {
    var Position: (CFloat, CFloat, CFloat)
    var Color: (CFloat, CFloat, CFloat, CFloat)
    var TexCoord: (CFloat, CFloat)
}

let TEX_COORD_MAX: CFloat = 1
var Vertices = [
    // Front
    Vertex(Position: (1, -1, 0) , Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0))
    , Vertex(Position: (1, 1, 0) , Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX))
    , Vertex(Position: (-1, 1, 0) , Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX))
    , Vertex(Position: (-1, -1, 0) , Color: (0, 0, 0, 1), TexCoord: (0, 0))

    // Back
    , Vertex(Position: (1, 1, -2) , Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0))
    , Vertex(Position: (-1, -1, -2) , Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX))
    , Vertex(Position: (1, -1, -2) , Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX))
    , Vertex(Position: (-1, 1, -2) , Color: (0, 0, 0, 1), TexCoord: (0, 0))

    // Left
    , Vertex(Position: (-1, -1, 0) , Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0))
    , Vertex(Position: (-1, 1, 0) , Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX))
    , Vertex(Position: (-1, 1, -2) , Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX))
    , Vertex(Position: (-1, -1, -2) , Color: (0, 0, 0, 1), TexCoord: (0, 0))

    // Right
    , Vertex(Position: (1, -1, -2) , Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0))
    , Vertex(Position: (1, 1, -2) , Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX))
    , Vertex(Position: (1, 1, 0) , Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX))
    , Vertex(Position: (1, -1, 0) , Color: (0, 0, 0, 1), TexCoord: (0, 0))

    // Top
    , Vertex(Position: (1, 1, 0) , Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0))
    , Vertex(Position: (1, 1, -2) , Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX))
    , Vertex(Position: (-1, 1, -2) , Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX))
    , Vertex(Position: (-1, 1, 0) , Color: (0, 0, 0, 1), TexCoord: (0, 0))

    // Bottom
    , Vertex(Position: (1, -1, -2) , Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0))
    , Vertex(Position: (1, -1, 0) , Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX))
    , Vertex(Position: (-1, -1, 0) , Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX))
    , Vertex(Position: (-1, -1, -2) , Color: (0, 0, 0, 1), TexCoord: (0, 0))

]


var Indices: [GLubyte] = [
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 5, 6,
    4, 5, 7,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
]

class OpenGLView: UIView {

    override init(frame: CGRect) {
        super.init(frame: .zero)

        p_actionWhenInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        p_actionWhenInit()
    }

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }


    deinit {
    }

    var _colorRenderBuffer: GLuint = 0
    let _context = EAGLContext(api: EAGLRenderingAPI.openGLES2)

    var _positionSlot: GLuint = 0
    var _colorSlot: GLuint = 0

    var _projectionUniform: GLuint = 0
    var _modelViewUniform: GLuint = 0
    var _currentRotation: GLfloat = 0

    var _depthRenderBuffer: GLuint = 0

    var _floorTexture: GLuint = 0
    var _fishTexture: GLuint = 0
    var _texCoordSlot: GLuint = 0
    var _textureUniform: GLuint = 0


    override func layoutSubviews() {
        super.layoutSubviews()

        setupLayer()
        setupContent()
        setupDepthBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        compileShaders()
        setupVBOs()
        setupDisplayLink()

        _floorTexture = setupTexture(fileName: "tile_floor.png")
        _fishTexture = setupTexture(fileName: "item_powerup_fish.png")
    }
    
}

extension OpenGLView {
    func p_actionWhenInit() {



    }
    func setupLayer() {
        layer.isOpaque = true
    }

    func setupContent() {

        guard _context != nil else {
            exit(1)
        }

        guard EAGLContext.setCurrent(_context) else {
            exit(1)
        }
    }

    func setupRenderBuffer() {
        glGenRenderbuffers(1, &_colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
        _context?.renderbufferStorage(Int(GL_RENDERBUFFER), from: layer as? EAGLDrawable)
    }

    func setupDepthBuffer() {
        glGenRenderbuffers(1, &_depthRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _depthRenderBuffer)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(frame.width), GLsizei(frame.height))
    }

    func setupTexture(fileName: String) -> GLuint {
        guard let spriteImage = UIImage(named: fileName)?.cgImage else {
            print("Failed to load image: \(fileName)")
            exit(1)
        }

        let width = spriteImage.width
        let height = spriteImage.height

        let spriteData = calloc(width*height*4, MemoryLayout<GLubyte>.size)
        let spriteContext = CGContext(data: spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width*4, space: spriteImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

        spriteContext?.draw(spriteImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var texName: GLuint = 0
        glGenTextures(1, &texName)
        glBindTexture(GLenum(GL_TEXTURE_2D), texName)


        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)

        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), spriteData)

        free(spriteData)

        return texName

    }

    func setupFrameBuffer() {
        var frameBuffer: GLuint = 0
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), _depthRenderBuffer)
    }

    @objc func render(displayLink: CADisplayLink) {
        glClearColor(0, 104.0/255.0, 55.0/255.0, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))

        let projection = CC3GLMatrix()
        let h: GLfloat = GLfloat(4.0 * frame.size.height / frame.size.width)
        projection?.populate(fromFrustumLeft: -2, andRight: 2, andBottom: -h/2, andTop: h/2, andNear: 4, andFar: 10)
        glUniformMatrix4fv(GLint(_projectionUniform), 1, 0, projection?.glMatrix)

        let modelView = CC3GLMatrix()
        modelView?.populate(fromTranslation: CC3Vector(x: GLfloat(sin(CACurrentMediaTime())), y: 0, z: -7))
        _currentRotation += GLfloat(displayLink.duration) * 90
        modelView?.rotate(by: CC3Vector(x: _currentRotation, y: _currentRotation, z: 0))
        glUniformMatrix4fv(GLint(_modelViewUniform), 1, 0, modelView?.glMatrix)

        glViewport(0, 0, GLsizei(frame.size.width), GLsizei(frame.size.height))


        glVertexAttribPointer(GLuint(_positionSlot), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), nil)

        let colorSlotFirstComponent = UnsafeRawPointer(bitPattern: MemoryLayout<CFloat>.size * 3)
        glVertexAttribPointer(GLuint(_colorSlot), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), colorSlotFirstComponent)

        let textureSlotFirstComponent = UnsafeRawPointer(bitPattern: MemoryLayout<CFloat>.size * 7)
        glVertexAttribPointer(_texCoordSlot, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), textureSlotFirstComponent)

        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), _floorTexture)
        glUniform1i(GLint(_textureUniform), 0)

        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)


        _context?.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }

    func compileShader(shaderName: String, type: GLenum) -> GLuint {
        guard let shaderString = Bundle.main.path(forResource: shaderName, ofType: "glsl")
            .flatMap({ try? String(contentsOfFile: $0)}) else { exit(1) }

        let shaderHandle = glCreateShader(type)

        var shaderStringUTF8 = (shaderString as NSString).utf8String
        var shaderStringLength: GLint = GLint((shaderString as NSString).length)
        glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength)

        glCompileShader(shaderHandle)

        var compileSuccess: GLint = GL_FALSE
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if compileSuccess == GL_FALSE {
            let bufferSize = 256
            let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: bufferSize)
            glGetShaderInfoLog(shaderHandle, GLsizei(bufferSize), nil, infoLog)
            let msgString = String(cString: infoLog)
            infoLog.deallocate(capacity: bufferSize)
            print(msgString)

            exit(1)
        }

        return shaderHandle

    }

    func compileShaders() {
        let vertexShader = compileShader(shaderName: "SimpleVertex", type: GLenum(GL_VERTEX_SHADER))
        let fragmentShader = compileShader(shaderName: "SimpleFragment", type: GLenum(GL_FRAGMENT_SHADER))

        let programHandle = glCreateProgram()
        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)
        glLinkProgram(programHandle)

        var linkSuccess = GL_FALSE
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
        if linkSuccess == GL_FALSE {
            let bufferSize = 256
            let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: bufferSize)
            glGetProgramInfoLog(programHandle, GLsizei(bufferSize), nil, infoLog)
            let msg = String(cString: infoLog)
            print(msg)

            exit(1)
        }

        glUseProgram(programHandle)

        _positionSlot = GLuint(glGetAttribLocation(programHandle, "Position"))
        _colorSlot = GLuint(glGetAttribLocation(programHandle, "SourceColor"))

        glEnableVertexAttribArray(_positionSlot)
        glEnableVertexAttribArray(_colorSlot)

        _projectionUniform = GLuint(glGetUniformLocation(programHandle, "Projection"))
        _modelViewUniform = GLuint(glGetUniformLocation(programHandle, "Modelview"))

        _texCoordSlot = GLuint(glGetAttribLocation(programHandle, "TexCoordIn"))
        glEnableVertexAttribArray(_texCoordSlot)
        _textureUniform = GLuint(glGetUniformLocation(programHandle, "Texture"))

    }

    func setupVBOs() {

        var vertexBuffer: GLuint = 0
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.count * MemoryLayout<Vertex>.size, Vertices, GLenum(GL_STATIC_DRAW))

        var indexBuffer: GLuint = 0
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), Indices.count * MemoryLayout<GLubyte>.size, Indices, GLenum(GL_STATIC_DRAW))

    }

    func setupDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(render(displayLink:)))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }
}

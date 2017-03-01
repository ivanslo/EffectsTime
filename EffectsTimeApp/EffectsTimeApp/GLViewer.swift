//
//  GLViewer.swift
//  EffectsTimeApp
//
//  Created by Ivan Slobodiuk
//  Copyright © 2017 sLab. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit

class GLViewer: GLKView {
    
    /* ------------------------------------------ */
    
    private var initialized : Bool = false
    
    /* ------------------------------------------ */
    
    private var shaderProgram   : GLuint = 0
    private var vertexArray     : GLuint = 0
    private var videoTexture    : GLuint = 0
    
    private var shader_invertFlagLocation   : GLint = 0
    private var shader_flipXFlagLocation    : GLint = 0
    
    /* ------------------------------------------ */
    
    private let textureVertices : [GLfloat] = [
        // square        |   uv
         1.0, -1.0, 0.0,    1.0, 1.0,
        -1.0, -1.0, 0.0,    0.0, 1.0,
        -1.0,  1.0, 0.0,    0.0, 0.0,
         1.0,  1.0, 0.0,    1.0, 0.0
    ]
    
    private let indices : [GLuint] = [
        0, 1, 3,
        1, 2, 3
    ]
    
    private var clearColor : [GLfloat] = [
        0.0, 0.0, 0.0, 1.0
    ]
    
    /* ------------------------------------------ */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    /* ------------------------------------------ */
    
    func initialize() {
        if initialized {
            return
        }
        let context = EAGLContext.init(api: EAGLRenderingAPI.openGLES2)
        EAGLContext.setCurrent(_:context)
        super.context = context!

        // shaders
        let vs = Shader.createShaderFromFile("textureVertex"    , ext: "glsl", shaderType: GLenum(GL_VERTEX_SHADER))
        let fs = Shader.createShaderFromFile("textureFragment"  , ext: "glsl", shaderType: GLenum(GL_FRAGMENT_SHADER))
        shaderProgram = Shader.createProgram(vertexShader: vs, fragmentShader: fs)
        glDeleteShader(vs)
        glDeleteShader(fs)
        
        glUseProgram(shaderProgram)
        shader_invertFlagLocation   = glGetUniformLocation(shaderProgram, "invertFlag")
        shader_flipXFlagLocation    = glGetUniformLocation(shaderProgram, "flipXFlag")
        
        var vbo : GLuint = 0
        var ebo : GLuint = 0
        
        glGenBuffers(1, &vbo)
        glGenBuffers(1, &ebo)
        
        // such a strange way to get sizeof(type), isn't it?
        let sizeof_GLfloat  = Int(GLsizei(MemoryLayout<GLfloat>.size))
        let sizeof_GLuint   = Int(GLsizei(MemoryLayout<GLuint>.size))
        
        glGenVertexArrays(1, &vertexArray)
        glBindVertexArray(vertexArray)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
            glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof_GLfloat * textureVertices.count,
                         textureVertices, GLenum(GL_STATIC_DRAW))
            
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), sizeof_GLuint * indices.count,
                         indices, GLenum(GL_STATIC_DRAW))
        
            // texturePosition attribute in the shaders
            let offsetPosition = UnsafeRawPointer(bitPattern: 0)
            glVertexAttribPointer( 0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof_GLfloat * 5), offsetPosition )
            glEnableVertexAttribArray(0)
            
            // textureCoordinate attribute in the shaders
            let offsetTexture = UnsafeRawPointer(bitPattern: Int(sizeof_GLfloat * 3))
            glVertexAttribPointer( 1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof_GLfloat * 5), offsetTexture )
            glEnableVertexAttribArray(1)
        glBindVertexArray(0)
        
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
        
        initialized = true
    }
    
    /* ------------------------------------------ */
    
    func drawFrame(_ effects : UInt8) {
        glClearColor(0.0, 0.0, 1.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        
        glUseProgram(shaderProgram)
        
        // apply effects to the shader (or not)
        let flipX       : Float = (effects & Effects.flipX.rawValue)        != 0 ? 1.0 : 0.0
        let invertColor : Float = (effects & Effects.invertColor.rawValue)  != 0 ? 1.0 : 0.0
        
        glUniform1f(shader_flipXFlagLocation, flipX)
        glUniform1f(shader_invertFlagLocation, invertColor)
        
        glActiveTexture(GLenum(GL_TEXTURE0));
        glBindTexture(GLenum(GL_TEXTURE_2D), videoTexture);
        
        glBindVertexArray(vertexArray)
            glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_INT), nil)
        glBindVertexArray(0)
        
        self.display()
    }
    
    func clearScreen() {
        if !initialized {
            initialize()
        }
        glClearColor(clearColor[0], clearColor[1], clearColor[2], clearColor[3]);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        self.display()
    }
    
    /* ------------------------------------------ */
    
    func processAndPresentFrame(_ pixelBuffer : CVPixelBuffer, apply effects: UInt8 ) {
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        //let width   = CVPixelBufferGetWidth(pixelBuffer)
        let height  = CVPixelBufferGetHeight(pixelBuffer)
        /* 
         * Calculate the extendedWidth is necessary because in some capture resolutions 
         * there are more bytes per row.
         * I.e: in portrait mode, capturing at 1080x1920 each row has 1088 bytes.
         */
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let extendedWidth = bytesPerRow / MemoryLayout<UInt32>.size;
        
        glGenTextures(1, &videoTexture)
        glBindTexture(GLenum(GL_TEXTURE_2D), videoTexture )
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(extendedWidth), GLsizei(height), 0, GLenum(GL_BGRA), GLenum(GL_UNSIGNED_BYTE), CVPixelBufferGetBaseAddress(pixelBuffer))
        
        drawFrame(effects)
        
        glDeleteTextures(1, &videoTexture)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
    }
 
}

//
//  Shader.swift
//  EffectsTimeApp
//
//  Created by Ivan Slobodiuk
//  Copyright © 2017 sLab. All rights reserved.
//

import Foundation


class Shader : NSObject {
    /* 
     * Helper class for creating shaders 
     */
    
    static func createProgram(vertexShader : GLuint, fragmentShader: GLuint) -> GLuint {
        let program = glCreateProgram()
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        glLinkProgram(program)
        
        var success: GLint = GLint()
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &success)
        if success == GLint(GL_FALSE) {
            print("glLinkProgram - failed")
        }
        return program
    }
    
    /* ------------------------------------------- */
    
    static func createShaderFromFile(_ fileName: String, ext: String, shaderType: GLenum ) -> GLuint {
        let shaderPath: String! = Bundle.main.path(forResource: fileName, ofType: ext)
        
        var shaderContentString : String?
        do {
            shaderContentString = try String(contentsOfFile: shaderPath, encoding: .utf8)
        } catch {
            print("Failed to read content of shader file ", fileName)
        }
        
        let shader: GLuint = glCreateShader(shaderType)
        if shader == 0 {
            print("glCreateShader - failed | ", fileName)
        }
        
        var shaderContentUTF8 = (shaderContentString! as NSString).utf8String
        var shaderContentLenght: GLint = Int32(shaderContentString!.characters.count)
        
        glShaderSource(shader, 1, &shaderContentUTF8, &shaderContentLenght)
        glCompileShader(shader)
        
        var success: GLint = GLint()
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &success)
        
        if( success == GLint(GL_FALSE) )
        {
            print("glCompileShader - failed | ", fileName)
        }
        return shader
    }
    
}


//                                                                                                                                      //
//                                                         N E O  E N G I N E                                                           //
//                                                                                                                                      //
//                                                 Copyright (C) 2016 Justin Squirek                                                    //
//                                                                                                                                      //
// Neo is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the //
// Free Software Foundation, either version 3 of the License, or (at your option) any later version.                                    //
//                                                                                                                                      //
// Neo is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of                //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.                            //
//                                                                                                                                      //
// You should have received a copy of the GNU General Public License along with Neo. If not, see gnu.org/licenses                       //
//                                                                                                                                      //

//   vertexSkinned {

//     // Attributes
//     layout (location = 0) in vec3 inPosition;
//     layout (location = 1) in vec3 inNormal;
//     layout (location = 2) in vec4 inWeights; // ((Weight, Index), (...))
//     layout (location = 3) in vec2 aTexCoords;
//     layout (location = 0) out vec4 outColor; 

//     void main (){

// // Attributes
// layout (location = 0) in  vec3  inPosition;
// layout (location = 1) in  vec3  inNormal;
// layout (location = 3) in  vec2  inTexCoords;
// layout (location = 0) out vec4  outColor; 

// // This is a simple 2 bone skinning shader
// void main (){

//   // The normal vertex is a weighted sum of the bone matrices applied to the normal - apply the bone matrix 3x3 rotation to the normal
//   vec3 Skinned_Normal = normalize (inBoneWeightA * (mat3 (skeleton [inBoneIndexA]) * inNormal) +
//                                    inBoneWeightB * (mat3 (skeleton [inBoneIndexB]) * inNormal));

//   // Compute the final position and vertex color.
//   gl_Position = MVP * vec4 ((inBoneWeightA * (skeleton [inBoneIndexA] * vec4 (inPosition, 1.0)) +
//                              inBoneWeightB * (skeleton [inBoneIndexB] * vec4 (inPosition, 1.0))).xyz, 1.0);

//   // Compute a simple diffuse lit vertex color with two lights
//   outColor.w = 1.0;
//   outColor.xyz = (vec3 (0.4, 0.0, 0.0) * dot (Skinned_Normal, Light_A.xyz) + vec3 (0.4, 0.2, 0.2)) +
//                   vec3 (0.4, 0.0, 0.0) * dot (Skinned_Normal, Light_B.xyz);
//   fragment.position  = vertex.position * MVP;
//   fragment.texcoord0 = (localViewOrigin - vertex.position).xyz;
//   fragment.texcoord1 = (vertex.normal * 2.0 - 1.0).xyz;
//   fragment.color     = color;

//   // ...
//   TexCoords = aTexCoords;
//   WorldPos = vec3(model * vec4(aPos, 1.0));
//   Normal = mat3(model) * aNormal;   

//   gl_Position =  projection * view * vec4(WorldPos, 1.0);
// }

// attribute vec3 tangent;

// varying vec3 lightVec;
// varying vec3 halfVec;
// varying vec3 eyeVec;


// -------------------------------------------------------
// Vertex shader's main entry point.
//
// Bump mapping with parallax offset.
// -------------------------------------------------------

void main (void)
{
  // output vertex position
  gl_Position = ftransform ();

  vec3 n = normalize (gl_NormalMatrix * gl_Normal);
  vec3 t = normalize (gl_NormalMatrix * tangent);
  vec3 b = cross (n, t);

  // output texture coordinates for decal and normal maps
  gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;

  // transform light and half angle vectors by tangent basis
  vec3 v;
  v.x = dot (vec3 (gl_LightSource[0].position), t);
  v.y = dot (vec3 (gl_LightSource[0].position), b);
  v.z = dot (vec3 (gl_LightSource[0].position), n);
  lightVec = normalize (v);

  v.x = dot (vec3 (gl_LightSource[0].halfVector), t);
  v.y = dot (vec3 (gl_LightSource[0].halfVector), b);
  v.z = dot (vec3 (gl_LightSource[0].halfVector), n);
  halfVec = normalize (v);

  eyeVec = vec3 (gl_ModelViewMatrix * gl_Vertex);
  v.x = dot (eyeVec, t);
  v.y = dot (eyeVec, b);
  v.z = dot (eyeVec, n);
  eyeVec = normalize (v);
}

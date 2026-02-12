// Define the start of the Shader block. The string "Custom/TextureAnaglyph" is the name you will see in the Unity Inspector dropdown.
Shader "Custom/TextureAnaglyph"
{
    // The "Properties" block defines the variables that will appear in the Unity Material Inspector UI.
    Properties
    {
        // Define a texture slot named "_MainTex". "Albedo (RGB)" is the label shown in Unity. "white" {} is the default value if nothing is assigned.
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        
        // Define a color picker named "_Color". The default value is (1,1,1,1) which is white (solid opaque).
        _Color ("Tint Color", Color) = (1,1,1,1)
        
        // Define a slider named "_Spread". This controls how far apart the Red and Blue layers are. Range is limited from 0 to 0.05.
        _Spread ("Anaglyph Spread", Range(0, 0.05)) = 0.01
    }

    // "SubShader" contains the actual instructions for the GPU. You can have multiple SubShaders for different hardware, but usually just one is fine.
    SubShader
    {
        // "Tags" tell Unity how to render this object. 
        // "RenderType"="Opaque" tells Unity this is a solid object (not transparent glass).
        // "Queue"="Geometry" tells Unity to draw this with the other solid objects (before transparent ones).
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        
        // "LOD 100" (Level of Detail) is a quality setting. 100 is standard for simple shaders.
        LOD 100

        // A "Pass" is a single drawing operation. The GPU draws the object once for every Pass. We only need 1 Pass here.
        Pass
        {
            // Start the CGPROGRAM block. This is where the actual HLSL/Cg code begins.
            CGPROGRAM
            
            // Tell the compiler that the function named "vert" is our Vertex Shader.
            #pragma vertex vert
            
            // Tell the compiler that the function named "frag" is our Fragment (Pixel) Shader.
            #pragma fragment frag
            
            // Include "UnityCG.cginc". This is a built-in Unity file containing helper functions and macros we need.
            #include "UnityCG.cginc"

            // Define a struct (data container) named "appdata".
            // This holds the data COMING FROM the 3D model (the Mesh).
            struct appdata
            {
                // The 3D position of the vertex in local space (x, y, z).
                float4 vertex : POSITION;
                
                // The UV texture coordinates of the vertex (u, v).
                float2 uv : TEXCOORD0;
            };

            // Define a struct named "v2f" (Vertex to Fragment).
            // This holds the data passed FROM the Vertex Shader TO the Fragment Shader.
            struct v2f
            {
                // The texture coordinates to use for the pixel.
                float2 uv : TEXCOORD0;
                
                // The final screen position of the pixel. SV_POSITION is a special system keyword required by the GPU.
                float4 vertex : SV_POSITION;
            };

            // Declare the variables we defined in the "Properties" block so the code can use them.
            // "sampler2D" is the data type for a texture.
            sampler2D _MainTex;
            
            // "_MainTex_ST" is a special variable Unity creates automatically to handle Texture Tiling and Offset.
            float4 _MainTex_ST;
            
            // The color variable (RGBA).
            float4 _Color;
            
            // The float variable for our slider.
            float _Spread;

            // ---------------------------------------------------------
            // THE VERTEX SHADER
            // This runs once for every corner (vertex) of the 3D model.
            // ---------------------------------------------------------
            v2f vert (appdata v)
            {
                // Create an empty "v2f" container to store our results.
                v2f o;
                
                // Convert the vertex position from "Object Space" (local) to "Clip Space" (screen coordinates).
                // This is the most important math operation in graphics!
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // Apply Unity's Tiling and Offset settings to the UV coordinates.
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                // Return the data to be used by the Fragment Shader.
                return o;
            }

            // ---------------------------------------------------------
            // THE FRAGMENT SHADER
            // This runs once for every single pixel on the screen that the object covers.
            // ---------------------------------------------------------
            fixed4 frag (v2f i) : SV_Target
            {
                // -- STEP 1: CALCULATE OFFSETS --
                
                // Create a new UV coordinate called "uvRed".
                // We take the original UV and SUBTRACT the spread amount from the X axis.
                // This shifts the texture to the LEFT.
                float2 uvRed = i.uv - float2(_Spread, 0);
                
                // Create a new UV coordinate called "uvCyan".
                // We take the original UV and ADD the spread amount to the X axis.
                // This shifts the texture to the RIGHT.
                float2 uvCyan = i.uv + float2(_Spread, 0);

                // -- STEP 2: SAMPLE TEXTURE --
                
                // Read the color from the texture using the LEFT-shifted UVs.
                // This will be used for our Red channel.
                fixed4 colR = tex2D(_MainTex, uvRed);
                
                // Read the color from the texture using the RIGHT-shifted UVs.
                // This will be used for our Cyan (Green/Blue) channels.
                fixed4 colC = tex2D(_MainTex, uvCyan);

                // -- STEP 3: COMBINE CHANNELS --
                
                // Create a new color variable "finalColor".
                // Red Channel (R) = Take the Red from the LEFT image (colR.r).
                // Green Channel (G) = Take the Green from the RIGHT image (colC.g).
                // Blue Channel (B) = Take the Blue from the RIGHT image (colC.b).
                fixed3 finalColor = fixed3(colR.r, colC.g, colC.b);

                // Multiply the result by the Tint Color set in the material inspector.
                finalColor *= _Color.rgb;

                // Return the final pixel color.
                // We construct a fixed4 (RGBA). The Alpha (A) is set to 1.0 (fully opaque).
                return fixed4(finalColor, 1.0);
            }
            // End of the CGPROGRAM block.
            ENDCG
        }
    }
}
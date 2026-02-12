// Define the shader path in Unity's Inspector.
// You will find this under the "Custom" category as "AnaglyphFusion".
Shader "Custom/AnaglyphFusion"
{
    // The Properties block defines the inputs exposed in the Unity Editor.
    Properties
    {
        // Slot for the Left Eye's Render Texture.
        // "2D" means it expects an image texture.
        // "white" {} is the default value if nothing is assigned.
        _LeftTex ("Left Eye Texture", 2D) = "white" {}

        // Slot for the Right Eye's Render Texture.
        _RightTex ("Right Eye Texture", 2D) = "white" {}
    }

    // The SubShader contains the actual GPU instructions.
    SubShader
    {
        // "RenderType"="Opaque" tells Unity this is a solid object.
        Tags { "RenderType"="Opaque" }

        // "Cull Off": Draw both sides of the mesh (important for UI planes).
        Cull Off 

        // "ZWrite Off": Do not write to the Depth Buffer.
        // We are rendering a UI overlay, so we don't want to mess up the depth sorting of 3D objects.
        ZWrite Off 

        // "ZTest Always": Always draw this pixel, regardless of what is in front or behind it.
        // This ensures our Anaglyph screen is always visible on top.
        ZTest Always

        // A Pass is a single drawing operation.
        Pass
        {
            // Start of the HLSL/Cg shader code.
            CGPROGRAM
            
            // Define the function name for the Vertex Shader (handles shape/position).
            #pragma vertex vert
            
            // Define the function name for the Fragment Shader (handles color/pixels).
            #pragma fragment frag
            
            // Include Unity's built-in helper library.
            #include "UnityCG.cginc"

            // Data structure coming FROM the mesh (the UI plane).
            struct appdata
            {
                // The 3D position of the vertex.
                float4 vertex : POSITION;
                
                // The texture coordinates (UVs).
                float2 uv : TEXCOORD0;
            };

            // Data structure passed FROM Vertex Shader TO Fragment Shader.
            struct v2f
            {
                // The texture coordinates to use for sampling.
                float2 uv : TEXCOORD0;
                
                // The final screen-space position of the vertex.
                float4 vertex : SV_POSITION;
            };

            // Declare the variables so the code can read the properties defined at the top.
            sampler2D _LeftTex;
            sampler2D _RightTex;

            // --- VERTEX SHADER ---
            // Runs once for every corner of the UI plane.
            v2f vert (appdata v)
            {
                v2f o;
                // Convert 3D world position to 2D screen position.
                o.vertex = UnityObjectToClipPos(v.vertex);
                // Pass the UVs through unchanged.
                o.uv = v.uv;
                return o;
            }

            // --- FRAGMENT SHADER ---
            // Runs for every single pixel on the screen.
            fixed4 frag (v2f i) : SV_Target
            {
                // 1. Sample the color from the Left Camera's texture.
                fixed4 colL = tex2D(_LeftTex, i.uv);
                
                // 2. Sample the color from the Right Camera's texture.
                fixed4 colR = tex2D(_RightTex, i.uv);

                // --- COLOR ANAGLYPH LOGIC ---

                // RED CHANNEL (Left Eye):
                // In a standard Red-Cyan anaglyph, the Left Eye sees through the Red filter.
                // So, we take the Red component from the Left Camera's image.
                float r = colL.r;

                // GREEN & BLUE CHANNELS (Right Eye / Cyan):
                // The Right Eye sees through the Cyan filter (which passes Green and Blue light).
                // So, we take the Green and Blue components from the Right Camera's image.
                float g = colR.g;
                float b = colR.b;

                // Combine them into the final pixel color.
                // Alpha is set to 1.0 (fully opaque).
                return fixed4(r, g, b, 1.0);
            }
            // End of shader code.
            ENDCG
        }
    }
}
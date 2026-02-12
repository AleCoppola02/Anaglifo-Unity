using UnityEditor;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

public class LookAtCamera : MonoBehaviour
{
    [SerializeField]
    private Camera target;
    // Drag your custom Anaglyph shader here in the Inspector
    public Shader anaglyphShader;

    // This will automatically find the "Universal Forward" or "Standard" shader
    private Shader defaultShader;
    private Renderer objRenderer;
    private bool isAnaglyphActive = false;
    private Texture texture;
    void Awake() {
        objRenderer = GetComponent<Renderer>();
        // Save the shader the object started with (the default one)
        defaultShader = objRenderer.material.shader;
        texture = objRenderer.material.GetTexture("_BaseMap");

    }

    // This is the function you requested
    public void SetAnaglyphMode(bool useAnaglyph) {
        // Prevent unnecessary processing if the value hasn't changed
        if (useAnaglyph == isAnaglyphActive) return;


        // 2. Switch the shader
        if (useAnaglyph) {
            objRenderer.material.shader = anaglyphShader;
            isAnaglyphActive = true;
        }
        else {
            objRenderer.material.shader = defaultShader;
            isAnaglyphActive = false;
        }

        // 3. Re-apply the texture to the new shader's specific slot
        // Your custom shader graph likely uses "_MainTex" as we set up earlier
        if (isAnaglyphActive)
            objRenderer.material.SetTexture("_MainTex", texture);
        else
            objRenderer.material.SetTexture("_BaseMap", texture);
    }


    // Update is called once per frame
    void Update()
    {
        transform.LookAt(transform.position - target.transform.position);
    }

}

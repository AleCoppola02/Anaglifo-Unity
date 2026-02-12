using UnityEngine;

public class AnaglyphRigController : MonoBehaviour
{
    [Header("Child Cameras")]
    [Tooltip("Drag the Left Camera object here")]
    public Transform leftCamera;
    [Tooltip("Drag the Right Camera object here")]
    public Transform rightCamera;

    [Header("3D Depth Settings")]
    [Range(0f, 0.5f)]
    [Tooltip("Distance between the two eyes in meters. 0.06 is average for humans.")]
    public float eyeSeparation = 0.06f;

    [Header("Movement Settings")]
    [Tooltip("How fast the camera moves left/right")]
    public float moveSpeed = 3.0f;
    [Tooltip("Maximum distance from the starting point in meters")]
    public float maxMoveDistance = 1.0f;

    // Internal variable to remember where we started
    private Vector3 startPosition;

    void Start() {
        // Record the starting position so we know where "center" is
        startPosition = transform.position;
    }

    void Update() {
        HandleMovement();
        UpdateEyeSeparation();
    }

    //This function provides basic camera movement for testing purposes.
    void HandleMovement() {
        // 1. Get Input (-1 for Left, +1 for Right)
        float inputX = Input.GetAxis("Horizontal");

        // 2. Calculate the new proposed position
        // current position + (direction * speed * time)
        Vector3 newPos = transform.position + (Vector3.right * inputX * moveSpeed * Time.deltaTime);

        // 3. Clamp the X value
        // We ensure the new X never goes below (Start - 1m) or above (Start + 1m)
        newPos.x = Mathf.Clamp(newPos.x, startPosition.x - maxMoveDistance, startPosition.x + maxMoveDistance);

        // 4. Apply the position
        transform.position = newPos;
    }

    //This function handles the offset of the right and left cameras.
    //IMPORTANT: THIS ASSUMES THAT THE RIGHT AND LEFT CAMERAS ARE CHILDREN OF THE MAIN CAMERA!!!
    void UpdateEyeSeparation() {
        // We use localPosition because these are children of the Main Camera.
        // This ensures they move relative to the parent, not the world.

        if (leftCamera != null) {
            // Move Left Camera to the negative (left) side of the parent
            leftCamera.localPosition = new Vector3(-eyeSeparation / 2f, 0f, 0f);
        }

        if (rightCamera != null) {
            // Move Right Camera to the positive (right) side of the parent
            rightCamera.localPosition = new Vector3(eyeSeparation / 2f, 0f, 0f);
        }
    }
}
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private Rigidbody2D body;
    [SerializeField] private float speed;
    private void Awake() {
        body = GetComponent<Rigidbody2D>();
    }

    private void Update() {
        body.linearVelocity = new Vector2(Input.GetAxis("Horizontal") * speed,body.linearVelocity.y);
        if(Input.GetKey(KeyCode.UpArrow)) {
            body.linearVelocity = new Vector2(body.linearVelocity.x, speed);
        }
    }

}

using NUnit.Framework;
using System.Collections.Generic;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.UI;

public class AnaglyphToggle : MonoBehaviour
{
    [SerializeField]
    List<LookAtCamera> billboards = new List<LookAtCamera>();
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    bool toggle;


    public void onToggle() {
        toggle = GetComponent<Toggle>().isOn;
        if(toggle == true) {
            for (int i = 0; i < billboards.Count; i++) {
                billboards[i].SetAnaglyphMode(toggle);
            }
        }
        return;
    }
}

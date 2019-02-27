using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEditor;

public class FlowMap : MonoBehaviour {
    public Texture2D renderTex;
    Texture2D _FlowMapTex;

    int sss = 10;

    // Use this for initialization
    void Start() {
        _FlowMapTex = new Texture2D(Screen.width, Screen.height);
    }



    public int SSS { get { return sss; } }
    // Update is called once per frame
    void Update () {
		
	}

}


# Effetto Anaglifo con due telecamere

Viene usato uno shader chiamato AnaglyphFusion.
Creare due Render Texture : LeftEye_RT, e RightEye_RT. La loro risoluzione deve essere uguale a quella dello schermo. Nel mio caso è impostata a 1920x1080. 

Creare un material chiamato Mat_Fusion. Lo shader del materiale deve essere impostato a AnaglyphFusion. Facendo questo, usciranno due campi "Left Eye Texture" e "Right Eye Texture". Trascinare le Render Texture in questi campi.

Nella scena, la Main Camera deve avere due figli, anch'esse Camere, chiamati CamLeft e CamRight. CamLeft ha un campo "Output Texture": in questo campo va trascinata la Render Texture LeftEye_RT. Ripetere la stessa operazione per CamLeft.

Creare un Canvas figlio della MainCamera, e in esso posizionare una "Raw Image". Il Canvas va impostato a Screen Space-Overlay. La Raw Image deve avere come materiale "Mat_Fusion". Per fare in modo che la Raw Image riempia lo schermo,  premere alt+shift e il quadratino in basso a destra negli Anchor Presets. 

Come funziona? Praticamente, le due telecamere left e right passano l'immagine che renderizzano alle render texture; queste due texture sono passate al materiale che, con lo shader, crea l'anaglifo, e questo anaglifo viene passato alla Raw Image nel canvas, che essendo screen space overlay ricoprirà tutta la visuale della telecamera.

Infine, la Main Camera ha uno script AnaglyphRigController che gestisce movimenti base, ma soprattutto gestisce l'offset delle due telecamere figlie, che determina quanto è forte l'effetto 3D. C'è un campo public, Eye Separation, che permette di gestire l'effetto. Aumentare la separazione significa aumentare la distanza tra la telecamera sinistra e destra.

Per evitare che la telecamera sprechi risorse renderizzando la scena, vanno cambiate alcune impostazioni nella main Camera. Dall'inspector della Camera, impostare Background Type da Skybox a Solid color (e impostarlo a nero). Come Culling Mask, deselezionare tutto tranne UI.

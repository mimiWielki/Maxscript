
-- plus: coordonner le chargement des sets avec leur selection 

rollout1 = execute(openFile ((getdir #scripts ) + "\zz_rig\Copy_paste_pose\Smart_anim_Pose_assistant.ms"))
rollout2 = execute(openFile ((getdir #scripts ) + "\zz_rig\Copy_paste_pose\Smart_anim_Pose_assistant_stock2.ms"))

newWindows = newRolloutFloater "Assistant de pose"  500 800

addRollout  rollout1 newWindows
addRollout  rollout2 newWindows


/*
rollout poseAssistUIRLT "Pose Assistant Rollout"
(
	subrollout poseAssistUIsubRLT height: 950
)

createdialog poseAssistUIRLT width: 500

AddSubRollout poseAssistUIRLT.poseAssistUIsubRLT stockSetRLT
AddSubRollout poseAssistUIRLT.poseAssistUIsubRLT poseAssistRLT
*/

-- marche � suivre pour enregistrer un set:
	-- selectionner le set
	-- cr�er un pose pour verrouiller la selection
	-- faire un "save as"pour memoriser le selection et les poses

-- marche � suivre pour modifier un set:
	-- supprimer toutes les poses du set, cela lib�re la selection
	-- modifier la selection
	-- cr�er un pose pour verrouiller la selection
	-- faire un "save as"pour memoriser le selection et les poses
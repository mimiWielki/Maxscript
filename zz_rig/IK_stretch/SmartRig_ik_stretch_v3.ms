-- AMELIORATION
-- aligner les controller spline sur les helpers
-- deplacer le controller d'orientation de l'ik vers l'avant dans la bonne direction
-- attacher les controlleur d'orientation des twist bones au helper du poignet plutot qu'au controlleur spline
-- sur le controlleur de ik placer un custom_attribute qui permette de selectionner des controlleur de rotation et position � la vol�e
-------------------------------------------------------------------------------------------------------------------------
--DEBUG

-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
fileIn "J:\_svn\DEV_maxscript\00_wip\zz_rig\bakBones.ms"

-- CREER UNE IK CHAIN
-- fonction
fn randomColor  =
(
	return (color (random 0 255) (random 0 255) (random 0 255));
)

--� partir de trois bones
os = $selection as array
if os.count == 3 do print "ok! good selection."

-- cr�ation de bak bones
BakBonesFN(os)

-- verifier que l'array est dans le bon sens

-- creation de trois point pour l'ikchain
wire_temp = randomColor ()
points_bn = for i = 1 to os.count collect 
(
point name: (uniquename "point_bn") rotation: os[i].rotation pos: os[i].pos \
	size: 4 box:true cross: true axistripod: false \
	boneEnable: true boneFreezeLength:false  wirecolor: red
)

for i = 2 to points_bn.count do points_bn[i].parent = points_bn[i-1]

-- creation de trois point pour le fk
wire_temp = randomColor ()
fkPointAr = for i = 1 to os.count collect 
(
	point name: (uniquename "fkPoint_") rotation: os[i].rotation pos: os[i].pos \
	size: 4 box:true cross: true axistripod: false \
	boneEnable: true boneFreezeLength: false  wirecolor: blue
)

for i = 2 to fkPointAr.count do fkPointAr[i].parent = fkPointAr[i-1]

-- creation de trois point espion de rotation
wire_temp = randomColor ()
bn_spy_rot = for i = 1 to os.count collect
(
	point name: (uniquename "bn_spy_rot") rotation: os[i].rotation pos: os[i].pos \
	size: 5 box:false cross: false axistripod:true wirecolor: yellow
)

for i = 1 to bn_spy_rot.count do bn_spy_rot[i].parent = points_bn[i]

-- cr�ation des trois target pour les bones
wire_temp = randomColor ()
ikTgtAr = for i = 1 to os.count collect
(
	point name: (uniquename "ikTgt_") rotation: os[i].rotation pos: os[i].pos \
	size: 5 box:true cross: false axistripod: false wirecolor: green
)

for i = 1 to ikTgtAr.count do ikTgtAr[i].parent = points_bn[i]

--cr�er une ik
ik_chain = IKSys.ikChain points_bn[1] points_bn[3] "IKHISolver"

--cr�ation de trois points pour le controle de l IK Chain
wire_temp = randomColor ()
points = for i = 1 to os.count collect
(
	point name: (uniquename "point_bn_ctr") rotation: bn_spy_rot[i].rotation \
	pos: points_bn[i].pos box: on axistripod: off size: 7  wirecolor: orange
)

-- ikTgtAr[1].parent = points[1]
ikTgtAr[3].parent = points[3]

--faire du point du milieu le controleur de la rotation de l'ik
ik_chain.transform.controller.VHTarget = points[2]

points_bn[2].transform.controller.PrefYAngle = 0
points_bn[2].transform.controller.PrefXAngle = 0

-- parente le premier os avec un helper
points_bn[1].parent = points[1] 

--parente ik_chain avec un helper
ik_chain.parent = points[3] 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

-- CREATION DU STRETCH

--A sur l'os du coude, preparation du controller de position en x
--1 cr�er une liste de controller de position en x 
--2 creer un bezier float pour memoriser la taille initiale de l'os
os2_pos = points_bn[2].transform.controller.FK_Sub_Control.controller.Position.controller

os2_pos.x_position.controller = bezier_float ()
os2_pos.x_position.controller = float_list ()

os2_pos_x = os2_pos.x_position.controller

--3 cr�er un script float pour d�larer le script
os2_pos_x.available.controller = float_script ()
os2_pos_x.setname 1 "zero"
os2_pos_x.setname 2 "stretch"

--4 activer le position script
os2_pos_x.setactive 2
os2_pos_x.weight[1].controller = bezier_float ()
os2_pos_x.weight[2].controller = bezier_float ()
os2_pos_x.weight[1].controller.value = 0

--5 variable: longueur du biceps fixe : biceps_fix = position en x de os[2]
os2_pos_x.stretch.controller.addconstant "biceps_fix" (points_bn[2].transform.controller.FK_Sub_Control.controller.Position.controller.x_position.controller.zero.controller)
os2_pos_x.stretch.controller.script = "biceps_fix.value"

--B preparation du controller de position en x sur l'os du poignet
--1 cr�er une liste de controller de position en x 
--2 creer un bezier float pour memoriser la taille initiale de l'os
os3_pos = points_bn[3].transform.controller.FK_Sub_Control.controller.Position.controller

os3_pos.x_position.controller = bezier_float ()
os3_pos.x_position.controller = float_list ()

os3_pos_x = os3_pos.x_position.controller

--3 cr�er un script float pour d�larer le script
os3_pos_x.available.controller = float_script ()
os3_pos_x.setname 1 "zero"
os3_pos_x.setname 2 "stretch"

--4 activer le position script
os3_pos_x.setactive 2
os3_pos_x.weight[1].controller = bezier_float ()
os3_pos_x.weight[2].controller = bezier_float ()
os3_pos_x.weight[1].controller.value = 0

--5 variable longueur de l'avant bras fixe : av_bras_fix = position en x de os[3]
os3_pos_x.stretch.controller.addconstant "av_bras_fix" (points_bn[3].transform.controller.FK_Sub_Control.controller.Position.controller.x_position.controller.zero.controller)
os3_pos_x.stretch.controller.script = "av_bras_fix.value"

--C �crire le script du coude
-----variables : point du coude comme node, point de l'epaule et longueur de l'avant bras
os2_pos_x.stretch.controller.addconstant "poignet" (points[3])
os2_pos_x.stretch.controller.addconstant "epaule" (points[1])
os2_pos_x.stretch.controller.addconstant "av_bras_fix" (points_bn[3].transform.controller.FK_Sub_Control.controller.Position.controller.x_position.controller.zero.controller)

os2_pos_x_str = stringstream  ""
format "arm_size = distance epaule poignet
arm_size_fix = biceps_fix.value + av_bras_fix.value
coef = arm_size / arm_size_fix
if arm_size > arm_size_fix then (biceps_fix.value*coef)  else (biceps_fix.value)" to: os2_pos_x_str
os2_pos_x.stretch.controller.script = os2_pos_x_str as string

--D �crire le script du poignet
-----variables : point du coude comme node, point de l'epaule et longueur du biceps
os3_pos_x.stretch.controller.addconstant "poignet" (points[3])
os3_pos_x.stretch.controller.addconstant "epaule" (points[1])
os3_pos_x.stretch.controller.addconstant "biceps_fix" (points_bn[2].transform.controller.FK_Sub_Control.controller.Position.controller.x_position.controller.zero.controller)

os3_pos_x_str = stringstream  ""
format "arm_size = distance epaule poignet
arm_size_fix = biceps_fix.value + av_bras_fix.value 
coef = arm_size/arm_size_fix 
if arm_size > arm_size_fix then (av_bras_fix.value*coef) else (av_bras_fix.value)" to: os3_pos_x_str
os3_pos_x.stretch.controller.script = os3_pos_x_str as string

---------------------------------------------------------------------------------------------------------------------------------------------
-- CREATION DES TARGETS POUR LES BONES



----------------------------------------------------------------------------------------------------------------------------------------------
-- CREATION DES CONTROLEURS SPLINE POUR IK
wire_temp = randomColor ()
crt_point_bns = for i = 1 to points.count collect 
(
	circle name: (uniquename "ctr_IK_") rotation: points[i].rotation pos: points[i].pos \
	radius: 10  wirecolor: red
)

for i = 1 to points.count do 
(
points[i].parent = crt_point_bns[i]
)

-- CREATION DES CONTROLEURS SPLINE POUR FK
wire_temp = randomColor ()
crt_FK_ = for i = 1 to points.count collect 
(
	circle name: (uniquename "ctr_FK_") rotation: fkPointAr[i].rotation pos: fkPointAr[i].pos \
	radius: 9  wirecolor: blue
)

for i = 1 to points.count do 
(
fkPointAr[i].parent = crt_FK_[i]
)

crt_FK_[2].parent = crt_FK_[1]
crt_FK_[3].parent = crt_FK_[2]

crt_FK_[2].position.controller.y_position.controller = float_script ()
crt_FK_[2].position.controller.z_position.controller = float_script ()

crt_FK_[2].rotation.controller.y_rotation.controller = float_script ()
crt_FK_[2].rotation.controller.x_rotation.controller = float_script ()

crt_FK_[3].position.controller.y_position.controller = float_script ()
crt_FK_[3].position.controller.z_position.controller = float_script ()


----------------------------------------------------------------------------------------------------------------------------------------------
-- TUNAGE DE BONES


-- creation des spy rot
wire_temp = randomColor ()

bn_spy_rot = for i = 1 to os.count collect
(
	point name: (uniquename "bn_spy_rot") rotation:os[i].rotation \
	pos:os[i].position  size: 1 box: false cross: false  axistripod: true wirecolor: wire_temp
)
for i = 1 to bn_spy_rot.count do bn_spy_rot[i].parent = os[i]

-- creation des hlpers de bones 
wire_temp = randomColor ()

bn_tune_hlps = for i = 1 to os.count collect 
(
	point name: (uniquename "bn_tune_hlp") rotation: os[i].rotation \
	pos: os[i].pos size: 5 box: false cross: true axistripod: false wirecolor: wire_temp
)

-- contrainte des bones aux helpers
for i= 1 to os.count do
(
	os[i].pos.controller = Position_Constraint ()
	print os[i]
	print bn_tune_hlps[i]
	os[i].pos.controller.constraints.appendTarget bn_tune_hlps[i] 100
)

for i= 1 to os.count-1 do
(
	os[i].rotation.controller = LookAt_Constraint ()
	os[i].rotation.controller.constraints.appendTarget bn_tune_hlps[i+1] 100
	os[i].rotation.controller.upnode_world = off
	os[i].rotation.controller.pickUpNode = bn_tune_hlps[i]
	os[i].rotation.controller.upnode_ctrl = 1
	os[i].rotation.controller.viewline_length_abs = off
)

----------------------------------------------------------------------------------------------------------------------------------------------
-- AJOUT DES CONTRAINTES

mobilPointAr = bn_tune_hlps
ikTgtAr =  ikTgtAr
fkTgtAr = fkPointAr

ctrPoint = point pos: [0,50,0]  name:(uniquename "FK target") box: on wirecolor: yellow

for i = 1 to 3 do
(
mobilPointAr[i].controller.pos.controller = position_xyz ()
mobilPointAr[i].controller.pos.controller = position_constraint ()
mobilPointAr[i].controller.pos.controller.constraints.appendTarget ikTgtAr[i] 100
mobilPointAr[i].controller.pos.controller.constraints.appendTarget fkTgtAr[i] 100

mobilPointAr[i].controller.rotation.controller = Euler_XYZ ()
mobilPointAr[i].controller.rotation.controller = Orientation_Constraint ()
mobilPointAr[i].controller.rotation.controller.constraints.appendTarget ikTgtAr[i] 100
mobilPointAr[i].controller.rotation.controller.constraints.appendTarget fkTgtAr[i] 100
)

-- definition des custom attributes

def = attributes transfertMod
(
	parameters main rollout:tranfertFKIK
	(
		stack_relais type:#nodetab tabSizeVariable:true 
	)

	rollout tranfertFKIK "Transfert" 
	(
	-- 	UI
		slider transfertSL "Transfert FK/IK"  type: #float  ticks: 5 range: [0,100,10]
		button printValBT "print value"
	-- 	events
		on tranfertFKIK open do
		(
			if stack_relais.count > 0 then
			(
				transfertSL.value = stack_relais[1].position.controller.weight[1]
			)
		)
		
		on transfertSL changed val do
		(
			for o in stack_relais do
			(
				o.position.controller.weight[1]  = val
				o.position.controller.weight[2]  = 100 - val
				
				o.rotation.controller.weight[1]  = val
				o.rotation.controller.weight[2]  = 100 - val
			)
		)
		
		on printValBT pressed do
		(
			if stack_relais.count > 0 then
			(
				print stack_relais[1].position.controller.weight[1]
				transfertSL.value = stack_relais[1].position.controller.weight[1]
			)
		)		
	)
)

-- ajout des parametres au modifier vide
select ctrPoint
print ctrPoint
modPanel.addModToSelection (emptymodifier ()) ui:on
custAttributes.add ctrPoint.modifiers[#'Attribute Holder'] def

for o in mobilPointAr do append	ctrPoint.modifiers["Attribute Holder"].stack_relais o

ctrPoint.modifiers["Attribute Holder"].stack_relais


--------------------------------------------------------------------------------------------------------------------------------------------------
-- TWIST DU BICEPS
-- twist du biceps

rootPoint = os[1].controller.position.controller.getnode 1
targetPoint = os[1].controller.rotation.controller.getnode 1

wire_temp = randomColor ()

pas = 0

-- contrainte de position
twistPointAr = for i = 1 to 4 collect
(
	pointTemp =  point name: (uniquename "twistPoint_") wirecolor: wire_temp size: 3 
	pointTemp.position.controller = position_constraint ()
	
	pointTemp.position.controller.appendTarget rootPoint (75 - pas)
	pointTemp.position.controller.appendTarget targetPoint (0 + pas)

	pointTemp.scale.controller = scaleXYZ ()
	pointTemp.scale.controller.x_scale.controller = float_script ()
	
	pointTemp.scale.controller.x_scale.controller.addnode "rootPoint" rootPoint
	pointTemp.scale.controller.x_scale.controller.addnode "targetPoint" targetPoint
	pointTemp.scale.controller.x_scale.controller.addconstant "refDist" ( distance rootPoint targetPoint )

	scaleXscript = stringstream ""
	format " (distance rootPoint targetPoint) / refDist " to: scaleXscript
	pointTemp.scale.controller.x_scale.controller.script = scaleXscript
	
	pas += 25
	pointTemp
)

-- contrainte de rotation
twistPointAr[1].rotation.controller = lookat_constraint ()	
twistPointAr[1].rotation.controller.appendTarget targetPoint 100
twistPointAr[1].rotation.controller.upnode_world = off
twistPointAr[1].rotation.controller.pickUpNode = points[1]
twistPointAr[1].rotation.controller.upnode_ctrl = 1
twistPointAr[1].rotation.controller.viewline_length_abs = off

twistPointAr[4].rotation.controller = orientation_constraint ()	
twistPointAr[4].rotation.controller.appendTarget targetPoint 100

twistPointAr[3].rotation.controller = lookat_constraint ()	
twistPointAr[3].rotation.controller.appendTarget targetPoint 100
twistPointAr[3].rotation.controller.upnode_world = off
twistPointAr[3].rotation.controller.pickUpNode =targetPoint
twistPointAr[3].rotation.controller.upnode_ctrl = 1
twistPointAr[3].rotation.controller.viewline_length_abs = off

twistPointAr[2].rotation.controller = euler_xyz ()	
twistPointAr[2].rotation.controller = orientation_constraint ()	
twistPointAr[2].rotation.controller.appendTarget twistPointAr[1] 100
twistPointAr[2].rotation.controller.appendTarget twistPointAr[3] 100

-- creation des bones
twist_bn = for i = 1 to (twistPointAr.count - 1 ) collect
(
	BoneSys.createBone twistPointAr[i].pos twistPointAr[i+1].pos  [1,0,0]
)

for i = 1 to 3 do twist_bn[i].parent =  twistPointAr[i] 

-- accrochage des bones aux helpers
for i = 1 to 3 do
(
	twist_bn[i].boneFreezeLength = false
	twist_bn[i].position.controller = position_constraint ()
	twist_bn[i].position.controller.appendTarget twistPointAr[i] 100
	
	twist_bn[i].rotation.controller = lookAt_constraint viewline_length_abs: false 
	twist_bn[i].rotation.controller.appendTarget twistPointAr[i+1] 100
)

--------------------------------------------------------------------------------------------------------------------------------------------------
-- TWIST DE L AVANT BRAS
-- twist de l'avant bras

rootPoint = os[2].controller.position.controller.getnode 1
targetPoint = os[2].controller.rotation.controller.getnode 1

wire_temp = randomColor ()

pas = 0

-- contrainte de position
twistPointAr = for i = 1 to 4 collect
(
	pointTemp =  point name: (uniquename "twistPoint_") wirecolor: green size: 3 
	pointTemp.position.controller = position_constraint ()
	
	pointTemp.position.controller.appendTarget rootPoint (75 - pas)
	pointTemp.position.controller.appendTarget targetPoint (0 + pas)
	
	pointTemp.scale.controller = scaleXYZ ()
	pointTemp.scale.controller.x_scale.controller = float_script ()
	
	pointTemp.scale.controller.x_scale.controller.addnode "rootPoint" rootPoint
	pointTemp.scale.controller.x_scale.controller.addnode "targetPoint" targetPoint
	pointTemp.scale.controller.x_scale.controller.addconstant "refDist" ( distance rootPoint targetPoint )

	scaleXscript = stringstream ""
	format " (distance rootPoint targetPoint) / refDist " to: scaleXscript
	pointTemp.scale.controller.x_scale.controller.script = scaleXscript
	
	pas += 25
	pointTemp
)

ctrPoint.scale.controller = scaleXYZ ()
ctrPoint.scale.controller.x_scale.controller = float_script ()

ctrPoint.scale.controller.x_scale.controller.addnode "rootPoint" rootPoint
ctrPoint.scale.controller.x_scale.controller.addnode "targetPoint" targetPoint
ctrPoint.scale.controller.x_scale.controller.addconstant "refDist" ( distance rootPoint targetPoint )

scaleXscript = stringstream ""
format " (distance rootPoint targetPoint) / refDist " to: scaleXscript
ctrPoint.scale.controller.x_scale.controller.script = scaleXscript

-- contrainte de rotation
twistPointAr[1].rotation.controller = orientation_constraint ()	
twistPointAr[1].rotation.controller.appendTarget rootPoint 100

twistPointAr[4].rotation.controller = orientation_constraint ()	
twistPointAr[4].rotation.controller.appendTarget targetPoint 100

twistPointAr[3].rotation.controller = lookat_constraint ()	
twistPointAr[3].rotation.controller.appendTarget targetPoint 100
twistPointAr[3].rotation.controller.upnode_world = off
twistPointAr[3].rotation.controller.pickUpNode =targetPoint
twistPointAr[3].rotation.controller.upnode_ctrl = 1
twistPointAr[3].rotation.controller.viewline_length_abs = off

twistPointAr[2].rotation.controller = orientation_constraint ()	
twistPointAr[2].rotation.controller.appendTarget rootPoint 100
twistPointAr[2].rotation.controller.appendTarget twistPointAr[3] 100

-- creation des bones
twist_bn = for i = 1 to (twistPointAr.count - 1 ) collect
(
	BoneSys.createBone twistPointAr[i].pos twistPointAr[i+1].pos  [1,0,0]
)

for i = 1 to 3 do twist_bn[i].parent =  twistPointAr[i] 

-- accrochage des bones aux helpers
for i = 1 to 3 do
(
	twist_bn[i].boneFreezeLength = false
	twist_bn[i].position.controller = position_constraint ()
	twist_bn[i].position.controller.appendTarget twistPointAr[i] 100

	twist_bn[i].rotation.controller = lookAt_constraint viewline_length_abs: false 
	twist_bn[i].rotation.controller.appendTarget twistPointAr[i+1] 100
)

delete os[1]
delete os[2]

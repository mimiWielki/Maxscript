-- AMELIORATION
-- aligner les controller spline sur les helpers
-- deplacer le controller d'orientation de l'ik vers l'avant dans la bonne direction
-- attacher les controlleur d'orientation des twist bones au helper du poignet plutot qu'au controlleur spline
-- sur le controlleur de ik placer un custom_attribute qui permette de selectionner des controlleur de rotation et position � la vol�e
-------------------------------------------------------------------------------------------------------------------------
--DEBUG

-------------------------------------------------------------------------------------------------------------------------
-- FONCTION pos_rot_script

fn pos_rot_script a1 a2 = 

(
				
				slave = a1
				master = a2

-- si l'eclave n'a pas deparent alors
				-- contrainte de position du substitut au nouveau controleur 
				slave.pos.controller = position_xyz ()
				slave.pos.controller = position_script ()

				slave.position.controller.AddNode "master" (master)
				slave.position.controller.Addnode "slave" (slave)
				
				pos_script = stringstream ""				
format "if slave.parent == undefined then master.position
else
in coordsys slave.parent master.position" to: pos_script
				close pos_script
				slave.position.controller.script = pos_script as string

				-- contrainte de rotation du substitut au nouveau controleur 
				slave.rotation.controller = Euler_xyz ()
				slave.rotation.controller = rotation_script ()
				
				slave.rotation.controller.AddNode "master" (master)
				slave.rotation.controller.AddNode "slave" (slave)
				
				rot_script = stringstream ""
format " if slave.parent == undefined then 
(
w = master.rotation.w
x = -1*(master.rotation.x)
y = -1*(master.rotation.y)
z = -1*(master.rotation.z)
(quat x y z w)
)
else
(
w = in coordsys slave.parent master.rotation.w
x = -1*(in coordsys slave.parent master.rotation.x)
y = -1*(in coordsys slave.parent master.rotation.y)
z = -1*(in coordsys slave.parent master.rotation.z)
(quat x y z w)
) " to: rot_script
				close rot_script
				slave.rotation.controller.script = rot_script as string
-- si l'esclave a un parent
)


-------------------------------------------------------------------------------------------------------------------------

-- CREER UNE IK CHAIN

--� partir de trois bones
os = $ as array

-- verifier que l'array est dans le bon sens
-- creation de trois point pour l'ikchain
points_bn = for i = 1 to os.count collect 
(
point name: (uniquename "point_bn") rotation: os[i].rotation pos:os[i].pos size: 3 boneEnable: true boneFreezeLength:false 

)

color_temp = color (random 0 255 ) (random 0 255 ) (random 0 255 )
for o in points_bn do o.wirecolor = color_temp

for i = 2 to points_bn.count do
points_bn[i].parent = points_bn[i-1]

-- creation de trois point espion de rotation
bn_spy_rot = for i = 1 to os.count collect
(
point name: (uniquename "bn_spy_rot") rotation: os[i].rotation pos:os[i].pos size: 5 box:false cross: false axistripod:true
)

color_temp = color (random 0 255 ) (random 0 255 ) (random 0 255 )
for o in bn_spy_rot do o.wirecolor = color_temp

for i = 1 to bn_spy_rot.count do bn_spy_rot[i].parent = os[i].parent

--cr�er une ik
ik_chain = IKSys.ikChain points_bn[1] points_bn[3] "IKHISolver"

-- CREER LES BONES TUNES

for i= 1 to os.count do
(
os[i].pos.controller = Position_Constraint ()
os[i].pos.controller.constraints.appendTarget points_bn[i] 100
)

for i= 1 to os.count-1 do
(
os[i].rotation.controller = LookAt_Constraint ()
os[i].rotation.controller.constraints.appendTarget points_bn[i+1] 100
os[i].rotation.controller.upnode_world = off
os[i].rotation.controller.pickUpNode = points_bn[i]
os[i].rotation.controller.upnode_ctrl = 1
os[i].rotation.controller.viewline_length_abs = off
)

--cr�ation de trois points pour controle des points bones
points = for i = 1 to os.count collect point name: (uniquename "point_bn_ctr") rotation:bn_spy_rot[i].rotation pos: points_bn[i].pos box: on axistripod: off size: 7

color_temp = color (random 0 255 ) (random 0 255 ) (random 0 255 )
for o in points do o.wirecolor = color_temp

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

os3_pos.x_position.controller   = bezier_float ()
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

-- CREATION DES CONTROLEURS SPLINE

crt_point_bns = for i = 1 to points.count collect 
(
circle name: (uniquename "ctr_point_bn") rotation: points[i].rotation pos: points[i].pos radius: 10
)

color_temp = color (random 0 255 ) (random 0 255 ) (random 0 255 )
for o in crt_point_bns do o.wirecolor = color_temp

for i = 1 to points.count do 
(
points[i].pos.controller = Position_Constraint ()
points[i].pos.controller.constraints.appendTarget crt_point_bns[i] 100
)

for i = 1 to points.count do
(
pos_rot_script points[i] crt_point_bns[i]
)

delete bn_spy_rot


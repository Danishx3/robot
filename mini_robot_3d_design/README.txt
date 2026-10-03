MINI COMPANION ROBOT CAR - PRINT PACKAGE
=======================================

Design target
-------------
The model follows the supplied reference image: a friendly four-wheel robot
with a camera/display head, rear-wheel drive, and front wheels that lift for
gesture animation.

Nominal assembled envelope (down pose)
--------------------------------------
Length: 230 mm
Width: 160 mm including the wheels
Height: 170 mm including the camera pod
Front wheel diameter: 64 mm
Rear wheel diameter: 72 mm

The model uses X for front-to-back (+X is the face), Y for width and Z for
height. The body is 207 x 96 x 70 mm. The head is 112 mm wide; the front
wheel track sets the overall 160 mm width. The front lifting arms pivot on metal
pins through the body sides; their servos should act through a linkage and
must not carry the robot's weight.

Printable parts
---------------
body.stl             Hollow main shell with head mount, axle holes and pivots
head.stl             Head shell with LCD, camera, speaker and neck openings
face_bezel.stl       Removable face display panel
wheel_arm_L.stl      Front lifting arm (print 1)
wheel_arm_R.stl      Mirrored-position front lifting arm (print 1)
wheel.stl            Front tire and hub geometry (print 2)
rear_wheel.stl       Rear drive tire and hub geometry (print 2)
axle_spacer.stl      Axle spacer; print as needed
battery_cover.stl    Removable underside cover
assembly.stl         Assembled visualization; do not print as one part
assembly.png         Isometric driving-pose preview
front_wheels_up.png  Isometric gesture-pose preview
front_view.png       Straight-on view showing the two wheel tracks
side_view.png        Side view showing the 230 mm overall length
mini_robot.scad      Parametric OpenSCAD source for all parts and poses

OpenSCAD export
---------------
Open mini_robot.scad and set PART to one of:
assembly, body, head, face_bezel, wheel_arm_L, wheel_arm_R, wheel,
rear_wheel, axle_spacer, or battery_cover. Render (F6) and export STL.

For the front wheels-down driving pose, set POSE = "down". For the raised
gesture pose, set POSE = "up". The POSE setting affects the assembly only;
the arms, wheels and body are separate printable parts. Set
SHOW_ELECTRONICS = true to display simplified component envelopes inside the
body in the OpenSCAD assembly view. Those envelopes are visualization aids,
not additional print parts. Set FAST_ASSEMBLY = true when exporting
assembly.stl to omit decorative tire treads and face graphics for a quicker
combined-mesh render. The individual wheel STLs retain their full detail.

Suggested hardware
------------------
- Raspberry Pi Zero 2 W and small LCD
- Camera module and small head-pan servo
- ESP32 controller and dual motor driver
- Two geared DC motors for the rear wheels
- Two high-torque metal-gear servos/actuators for lifting the front arms
- Protected 2S battery, DC-DC converter, microphone and speaker
- M3 fasteners, metal pivot pins and bushings or bearings

Assembly notes
--------------
1. Print the body and head, then fit the screen and camera from inside.
2. Fit the Pi, ESP32, driver, battery, audio parts and wiring through the open
   underside; secure the battery cover with four M3 screws.
3. Install the rear drive motors and wheels on 8 mm axles.
4. Mount each lifting arm on a metal pin/bushing at the body-side pivot.
   Couple the actuator through a linkage so the pivot pin carries the load.
5. Install the front wheels, route their wiring clear of the arm sweep, and
   set both DOWN and UP limits before enabling gestures.
6. Fit the head over the turntable ring and calibrate its pan servo.

Print suggestions
-----------------
Body/head/cover: PLA or PETG, 0.20 mm layers, 3-4 walls, 15-25% infill.
Wheel arms: PETG or strong PLA, 4-5 walls, 30-40% infill.
Wheels: TPU for grip or PETG for a rigid prototype.
Use supports only where the slicer requires them. Check actual servo, motor,
screen, battery and bearing dimensions before committing to a full print.

Safety
------
This is a hobby prototype, not a validated mechanical product. Check fit,
fastener strength, actuator torque, battery protection and center of gravity
on the physical build before autonomous operation.

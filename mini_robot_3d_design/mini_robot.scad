// Mini companion robot car, dimensioned from reference.png.
// Units are millimetres. X is front/back (+X is the face), Y is width,
// and Z is vertical. Set PART before exporting an individual STL.

$fn = 64;
$fs = 0.8;

PART = "assembly";       // assembly, body, head, face_bezel, wheel_arm_L,
                         // wheel_arm_R, wheel, rear_wheel, axle_spacer,
                         // battery_cover
POSE = "down";           // down or up (front wheel gesture pose for assembly)
SHOW_ELECTRONICS = false;

// ---------- REFERENCE DIMENSIONS ----------
// Nominal envelope: 230 mm long x 160 mm wide x 170 mm tall.
body_L = 207;
body_W = 112;
body_H = 60;
body_bottom = 34;
wall = 3;

head_L = 72;             // front/back depth
head_W = 112;
head_H = 70;
head_center_x = body_L - head_L/2 - 6;

wheel_D = 64;
wheel_W = 19;
rear_wheel_D = 72;
rear_wheel_W = 22;
axle_D = 8;

arm_len = 46;
arm_thick = 14;
pivot_D = 22;
front_pivot_x = 173;
front_pivot_z = 39;
front_arm_y = body_W/2 + 2;
front_wheel_y = body_W/2 + 14;
rear_axle_x = 29;
rear_wheel_y = body_W/2 + 12;
front_wheel_angle = POSE == "up" ? -65 : 65;

// ---------- GEOMETRY HELPERS ----------
module rounded_box(sz=[20,20,20], r=5, center=false) {
    x = sz[0];
    y = sz[1];
    z = sz[2];
    translate(center ? [-x/2,-y/2,-z/2] : [0,0,0])
        hull() {
            for (xx=[r,x-r])
                for (yy=[r,y-r])
                    translate([xx,yy,0]) cylinder(h=z,r=r);
        }
}

module y_cylinder(d=10,h=10) {
    rotate([90,0,0]) cylinder(d=d,h=h,center=true);
}

module x_cylinder(d=10,h=10) {
    rotate([0,90,0]) cylinder(d=d,h=h,center=true);
}

// A rounded slot through an X-facing panel. width runs along Y, height along Z.
module x_slot(depth=4,width=30,height=8,r=2) {
    rotate([0,90,0]) rounded_box([height,width,depth],r,true);
}

module capsule2d(len=40,dia=14) {
    hull() {
        translate([0,0]) circle(d=dia);
        translate([len,0]) circle(d=dia);
    }
}

// ---------- MAIN BODY ----------
module body_shell() {
    union() {
        difference() {
            rounded_box([body_L,body_W,body_H],18);

            // Hollow electronics bay, open underneath; retain a 3 mm roof.
            translate([wall,wall,-1])
                rounded_box([body_L-2*wall,body_W-2*wall,body_H-wall+1],15);

            // Rear drive axles pass through the two side walls.
            for (side=[-1,1])
                translate([rear_axle_x,body_W/2+side*body_W/2,2])
                    y_cylinder(d=axle_D+0.5,h=14);

            // Front lifting-arm pivots. Metal pins/bushings carry the load.
            for (side=[-1,1])
                translate([front_pivot_x,body_W/2+side*body_W/2,front_pivot_z])
                    y_cylinder(d=8.5,h=14);

            // Head pan mount opening and wiring pass-through.
            translate([head_center_x,body_W/2,body_H-1]) cylinder(d=38,h=10);
            translate([head_center_x,body_W/2,body_H-1]) cylinder(d=9,h=14);

            // Chest button and lower speaker/vent recesses on the front face.
            translate([body_L-1,body_W/2,body_H*0.69])
                x_slot(depth=5,width=30,height=10,r=4);
            translate([body_L-1,body_W/2,body_H*0.31])
                x_slot(depth=5,width=34,height=9,r=3);
            translate([body_L-1,body_W/2,body_H*0.16])
                x_slot(depth=5,width=18,height=7,r=2);

            // Three shallow cooling slots on the rear panel.
            for (z=[body_H*0.35,body_H*0.48,body_H*0.61])
                translate([1,body_W/2,z])
                    x_slot(depth=5,width=42,height=3,r=1.2);

            // Rear USB/charging opening.
            translate([1,body_W/2,body_H*0.22])
                x_slot(depth=5,width=22,height=10,r=2);
        }

        // Four internal screw towers support the removable battery cover.
        for (x=[12,body_L-12])
            for (y=[12,body_W-12])
                translate([x,y,0])
                    difference() {
                        cylinder(h=9,d=9);
                        translate([0,0,-1]) cylinder(h=11,d=3.4);
                    }

        // Low-profile head turntable ring on the top deck.
        translate([head_center_x,body_W/2,body_H-3])
            difference() {
                cylinder(h=6,d=52);
                translate([0,0,-1]) cylinder(h=8,d=38);
            }
    }
}

// ---------- HEAD AND FACE ----------
module head_shell() {
    union() {
        difference() {
            rounded_box([head_L,head_W,head_H],18,true);

            // Internal head cavity opens at the bottom for the display cable.
            translate([-(head_L-2*wall)/2,-(head_W-2*wall)/2,-head_H/2-1])
                rounded_box([head_L-2*wall,head_W-2*wall,head_H-wall],14);

            // Front LCD aperture and camera lens opening.
            translate([head_L/2-1,0,-2]) x_slot(depth=8,width=head_W-20,height=head_H-22,r=10);
            translate([head_L/2-1,0,head_H/2-8]) x_cylinder(d=8.5,h=10);
            translate([head_L/2+1,0,head_H/2-8]) x_cylinder(d=13,h=3);

            // Side speaker apertures and bottom neck passage.
            for (side=[-1,1])
                translate([-head_L*0.10,side*head_W/2,0])
                    y_cylinder(d=19,h=12);
            translate([0,0,-head_H/2+5]) cylinder(d=27,h=18,center=true);
        }

        // Neck collar nests inside the turntable ring and leaves room for wiring.
        translate([0,0,-head_H/2-5])
            difference() {
                cylinder(h=10,d=34);
                translate([0,0,-1]) cylinder(h=12,d=24);
            }
    }
}

// Removable black display glass/bezel; facial graphics are shown in assembly.
module face_bezel() {
    difference() {
        rounded_box([3,head_W-20,head_H-22],10,true);
        translate([0,0,head_H/2-6]) x_cylinder(d=8.5,h=6);
    }
}

// ---------- FRONT WHEEL LIFTING ARM ----------
// Local origin is the pivot; local +X runs out to the wheel axle.
module wheel_arm() {
    difference() {
        union() {
            rotate([90,0,0])
                linear_extrude(height=arm_thick,center=true)
                    capsule2d(arm_len,15);
            translate([0,0,0]) y_cylinder(d=pivot_D,h=arm_thick+8);
            translate([arm_len,0,0]) y_cylinder(d=16,h=arm_thick+6);
        }
        translate([0,0,0]) y_cylinder(d=8.5,h=arm_thick+16);
        translate([arm_len,0,0]) y_cylinder(d=axle_D+0.35,h=arm_thick+14);
    }
}

// ---------- WHEELS ----------
module wheel(d=wheel_D,w=wheel_W) {
    difference() {
        union() {
            rotate([90,0,0]) cylinder(d=d,h=w,center=true);
            y_cylinder(d=d*0.43,h=w+1.6);

            // Five raised spokes sit over the recessed wheel cheeks.
            for (a=[0:72:288])
                for (side=[-1,1])
                    rotate([0,a,0])
                        translate([d*0.13,side*(w/2+0.65),0])
                            cube([d*0.25,1.5,4],center=true);
        }

        y_cylinder(d=axle_D+0.35,h=w+5);

        // Recessed sidewalls leave a clear center hub and a durable tread ring.
        for (side=[-1,1])
            translate([0,side*(w/2-0.7),0])
                y_cylinder(d=d*0.72,h=1.5);

        // Shallow axial tread cuts around the circumference.
        for (a=[0:15:345])
            rotate([0,a,0])
                translate([d/2-1.2,0,0])
                    y_cylinder(d=1.7,h=w+1);
    }
}

module axle_spacer() {
    difference() {
        cylinder(h=10,d=14);
        translate([0,0,-1]) cylinder(h=12,d=axle_D+0.3);
    }
}

module battery_cover() {
    cover_L = body_L-2*wall;
    cover_W = body_W-2*wall;
    difference() {
        rounded_box([cover_L,cover_W,3],6);
        for (x=[9,cover_L-9])
            for (y=[9,cover_W-9])
                translate([x,y,-1]) cylinder(h=5,d=3.5);
    }
}

// ---------- ASSEMBLY DETAILS ----------
module x_ring(outer_d=20,inner_d=14,depth=1) {
    difference() {
        x_cylinder(d=outer_d,h=depth);
        x_cylinder(d=inner_d,h=depth+1);
    }
}

module y_ring(outer_d=30,inner_d=22,depth=2) {
    difference() {
        y_cylinder(d=outer_d,h=depth);
        y_cylinder(d=inner_d,h=depth+1);
    }
}

module wheel_hub_accent(x,y,z,side,w) {
    translate([x,y+side*(w/2+1.25),z]) {
        rotate([90,0,0]) {
            color("#ff6a1a") difference() {
                cylinder(d=32,h=1.4,center=true);
                cylinder(d=23,h=2,center=true);
            }
            color("#262b32") cylinder(d=13,h=1.8,center=true);
        }
    }
}

module face_graphics(front_x,center_y,center_z) {
    // Cyan eye rings and a small curved smile on the animated display.
    for (y=[center_y-23,center_y+23])
        translate([front_x, y, center_z+4])
            color("#49c9ff") x_ring(outer_d=15,inner_d=11,depth=1.1);

    smile = [[-11,-10],[-7,-13],[-3,-15],[0,-15.5],[3,-15],[7,-13],[11,-10]];
    for (i=[0:len(smile)-2])
        hull() {
            translate([front_x,center_y+smile[i][0],center_z+smile[i][1]])
                color("#49c9ff") sphere(r=1.2);
            translate([front_x,center_y+smile[i+1][0],center_z+smile[i+1][1]])
                color("#49c9ff") sphere(r=1.2);
        }
}

module electronics_visual() {
    // Simplified, removable component envelopes for the optional cutaway view.
    // These are visualization aids, not printable mounting models.
    color("#20252c") translate([18,body_W/2,body_bottom+17])
        rounded_box([78,48,24],5,true);                 // 2S battery pack
    color("#237a52") translate([100,body_W/2,body_bottom+24])
        rounded_box([70,52,2],4,true);                  // Raspberry Pi tray
    color("#318b5d") translate([153,body_W/2,body_bottom+16])
        rounded_box([46,32,2],3,true);                  // ESP32/controller
    color("#d48926") translate([147,body_W/2,body_bottom+33])
        rounded_box([38,24,10],3,true);                 // DC-DC + driver
    color("#20252c") translate([front_pivot_x,body_W/2,body_bottom+front_pivot_z-11])
        rounded_box([28,body_W-18,15],4,true);          // servo bay
}

module front_wheel_unit(side,angle) {
    pivot_x = front_pivot_x;
    pivot_y = body_W/2 + side*front_arm_y;
    axle_x = pivot_x + arm_len*cos(angle);
    axle_z = body_bottom + front_pivot_z - arm_len*sin(angle);
    wheel_y = body_W/2 + side*front_wheel_y;

    translate([pivot_x,pivot_y,body_bottom+front_pivot_z])
        rotate([0,angle,0])
            color("#f5f5f2") wheel_arm();

    translate([axle_x,wheel_y,axle_z]) color("#20242a") wheel();
    wheel_hub_accent(axle_x,wheel_y,axle_z,side,wheel_W);

    // Orange hinge cover and dark center bolt.
    translate([pivot_x,body_W/2+side*(front_arm_y+arm_thick/2+1),body_bottom+front_pivot_z]) {
        rotate([90,0,0]) {
            color("#ff6a1a") cylinder(d=20,h=1.5,center=true);
            color("#262b32") cylinder(d=8,h=2.2,center=true);
        }
    }
}

module rear_wheel_unit(side) {
    x = rear_axle_x;
    y = body_W/2 + side*rear_wheel_y;
    z = body_bottom + 2;
    translate([x,y,z]) color("#20242a") wheel(rear_wheel_D,rear_wheel_W);
    wheel_hub_accent(x,y,z,side,rear_wheel_W);
}

module assembly() {
    head_x = head_center_x;
    head_z = body_bottom + body_H + head_H/2;
    screen_x = head_x + head_L/2 - 1;
    body_face_z = body_bottom + body_H*0.69;

    translate([0,0,body_bottom]) color("#f4f4f1") body_shell();
    translate([wall,wall,body_bottom-2]) color("#d9dcde") battery_cover();

    // Main head and the flush LCD panel.
    translate([head_x,body_W/2,head_z]) color("#f4f4f1") head_shell();
    translate([screen_x,body_W/2,head_z-2]) color("#090d12") face_bezel();
    face_graphics(screen_x+2.2,body_W/2,head_z-2);

    // Camera housing above the display.
    translate([screen_x+2.5,body_W/2,head_z+head_H/2-1]) {
        color("#171c22") rounded_box([9,14,14],3,true);
        translate([5,0,-7]) rotate([0,90,0])
            color("#050709") cylinder(d=7,h=1.5,center=true);
    }

    // Orange ear trim around the side speaker ports.
    for (side=[-1,1])
        translate([head_x-head_L*0.10,body_W/2+side*(head_W/2+0.7),head_z])
            rotate([90,0,0]) color("#ff6a1a") y_ring(outer_d=31,inner_d=22,depth=2);

    // Chest button, grille and lower dark sensor slot.
    translate([body_L+0.5,body_W/2,body_face_z])
        rotate([0,90,0]) color("#ff6a1a") rounded_box([10,30,2],4,true);
    translate([body_L+0.45,body_W/2,body_bottom+body_H*0.31])
        rotate([0,90,0]) color("#1e242a") rounded_box([9,34,1.5],3,true);
    translate([body_L+0.45,body_W/2,body_bottom+body_H*0.16])
        rotate([0,90,0]) color("#171c22") rounded_box([7,18,1.5],2,true);

    // Four-wheel stance, with lifting front wheels in either reference pose.
    for (side=[-1,1]) {
        rear_wheel_unit(side);
        front_wheel_unit(side,front_wheel_angle);
    }

    if (SHOW_ELECTRONICS) electronics_visual();
}

// ---------- PART EXPORT ----------
if (PART == "body") body_shell();
else if (PART == "head") head_shell();
else if (PART == "face_bezel") face_bezel();
else if (PART == "wheel_arm_L") wheel_arm();
else if (PART == "wheel_arm_R") wheel_arm();
else if (PART == "wheel") wheel();
else if (PART == "rear_wheel") wheel(rear_wheel_D,rear_wheel_W);
else if (PART == "axle_spacer") axle_spacer();
else if (PART == "battery_cover") battery_cover();
else assembly();

wall_strength = 5;  //.1
base_height = 5;    //.1
inner_width = 65; //.1
wall_height = 38;   //.1


// List of tuples. First element is the angle, second element the distance towards the left side (+ outer_spacing)·
cutout_angles = [
    [90, 0],
    [45, 60],
    [135, 60]];
outer_spacing = 30; //.1
// make this slightly bigger than the thickness of your saw-blade
cutout_width = 2.0; //.1
// Amount the cutouts cut into the base to prevent the mitre box to be sawn through
cutout_groove = 1.0;    //.1

/* [Hidden] */
// Small value to prevent z-fighting
epsilon = 0.001;

_total_width = inner_width + 2 * wall_strength;

function calc_width(angle, length) = sin(angle) * length / 2;

function get_max_x_dimention(cutout_angles, maximum=0, idx=0) = idx < len(cutout_angles) - 1 ? max(maximum, get_max_x_dimention(cutout_angles, maximum, idx + 1)) : cutout_angles[idx][1] + (sin((cutout_angles[idx][0] % 180) - 90) * _total_width / cos((cutout_angles[idx][0] % 180) - 90) / 2) + (cutout_width);

length = 2 * outer_spacing + get_max_x_dimention(cutout_angles);
echo(length);



module angle_cutouts(cutout_angles, idx=0) {
    if(idx < len(cutout_angles) - 1) {
        angle_cutouts(cutout_angles, idx + 1);
    }
    angle = (cutout_angles[idx][0] % 180) - 90;
    height = wall_height + cutout_groove + epsilon;
    
    
    _cutout_length = _total_width / cos(angle);
    _offset_y = abs(sin(angle)) * (cutout_width/2);
    _offset_x = (sin(angle) * _cutout_length / 2) + (cutout_width / 2);
    _length_add = 2 * sqrt(pow((cutout_width/2) / sin(90 - angle), 2) - pow((cutout_width/2), 2)); // cutout_width * abs(sin(angle));

    translate([cutout_angles[idx][1] + _offset_x, -epsilon - _offset_y, -cutout_groove]) rotate([0, 0, angle]) translate([-cutout_width/2, 0, 0]) cube([cutout_width, _cutout_length + _length_add + 2 * epsilon, height]);
}


difference() {
    cube([length, inner_width + 2 * wall_strength, base_height + wall_height]);
    translate([-epsilon, wall_strength, base_height]) cube([length + 2 * epsilon, inner_width, wall_height + epsilon]);
    translate ([outer_spacing, 0, base_height]) angle_cutouts(cutout_angles);
}

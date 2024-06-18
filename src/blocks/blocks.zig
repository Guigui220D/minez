pub const air = struct {
    pub const dig_time = -1.0;
    pub const texture = "air.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 3;
        };
    };
};

pub const dirt = struct {
    pub const dig_time = 0.2;
    pub const texture = "dirt.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 1.1;
        };
    };
};

pub const stone = struct {
    pub const dig_time = 0.5;
    pub const texture = "stone1.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 1.1;
        };
    };
};

pub const iron = struct {
    pub const dig_time = 0.6;
    pub const texture = "iron.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 3;
        };
    };
};

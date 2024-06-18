pub const air = struct {
    pub const dig_time = -1.0;
    pub const texture = "air.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 2;
        };
    };
};

pub const dirt = struct {
    pub const dig_time = 0.2;
    pub const texture = "dirt.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 2;
        };
    };
};

pub const stone1 = struct {
    pub const dig_time = 0.5;
    pub const texture = "stone1.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 2;
        };
    };
};

pub const stone2 = struct {
    pub const dig_time = 0.6;
    pub const texture = "stone2.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 2;
        };
    };
};

pub const stone3 = struct {
    pub const dig_time = 0.7;
    pub const texture = "stone3.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 2;
        };
    };
};

pub const iron = struct {
    pub const dig_time = 0.6;
    pub const texture = "iron.png";
    pub const score = 100;
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 1.5;
            pub const stone2 = 0;
            pub const stone3 = 0;
            pub const dirt = 0;
        };
    };
};

pub const stronk = struct {
    pub const dig_time = 3;
    pub const texture = "stronk.png";
    pub const score = 100;
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 2.0;
        };
        pub const diag = struct {
            pub const self = 0;
        };
    };
};

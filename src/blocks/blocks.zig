pub const air = struct {
    pub const dig_time = -1.0;
    pub const texture = "air.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const all = 0;
            pub const stone4 = 1;
            pub const stalagmite = 1;
            pub const self = 1;
            pub const dirt = 1;
        };
        pub const diag = struct {
            pub const self = 0.8;
        };
        pub const close = struct {
            pub const self = 1.8;
            pub const stone2 = 0.0;
            pub const stone3 = 0.0;
        };
    };
};

pub const err_block = struct {
    pub const dig_time = 3;
    pub const texture = "error.png";
};

pub const dirt = struct {
    pub const dig_time = 0.2;
    pub const texture = "dirt.png";
    pub const wfc = struct {
        pub const close = struct {
            pub const all = 0.8;
            pub const self = 1.5;
            pub const stone2 = 0;
            pub const stone3 = 0;
            pub const stone4 = 0;
        };
    };
};

pub const stone1 = struct {
    pub const dig_time = 0.5;
    pub const texture = "stone1.png";
    pub const wfc = struct {
        pub const close = struct {
            pub const self = 1.8;
            pub const stone3 = 0;
            pub const stone4 = 0;
        };
    };
};

pub const stone2 = struct {
    pub const dig_time = 0.6;
    pub const texture = "stone2.png";
    pub const wfc = struct {
        pub const close = struct {
            pub const self = 1.5;
            pub const dirt = 0;
            pub const stone4 = 0;
        };
    };
};

pub const stone3 = struct {
    pub const dig_time = 0.7;
    pub const texture = "stone3.png";
    pub const wfc = struct {
        pub const close = struct {
            pub const self = 1.5;
            pub const stone1 = 0;
        };
    };
};

pub const stone4 = struct {
    pub const dig_time = 0.8;
    pub const texture = "stone4.png";
    pub const wfc = struct {
        pub const any = struct {
            pub const self = 2;
        };
        pub const sides = struct {
            pub const air = 0.01;
        };
    };
};

pub const stalagmite = struct {
    pub const dig_time = 0.8;
    pub const texture = "stalagmite.png";
    pub const wfc = struct {
        pub const close = struct {
            pub const self = 0.1;
        };
        pub const up = struct {
            pub const all = 0.0;
            pub const stone4 = 1.0;
        };
        pub const diagup = struct {
            pub const all = 0.0;
            pub const stone4 = 1.0;
        };
        pub const down = struct {
            pub const all = 0.0;
            pub const air = 1.0;
        };
    };
};

pub const iron = struct {
    pub const dig_time = 0.6;
    pub const texture = "iron.png";
    pub const score = 100;
    pub const wfc = struct {
        pub const close = struct {
            pub const self = 1.5;
            pub const stone2 = 0.1;
            pub const stone3 = 0.1;
            pub const stone4 = 0.1;
            pub const dirt = 0.1;
        };
    };
};

const stronk = struct {
    pub const dig_time = 3;
    pub const texture = "stronk.png";
    pub const score = 100;
    pub const wfc = struct {
        pub const close = struct {
            pub const self = 8.0;
        };
        pub const diag = struct {
            pub const self = 0.2;
        };
    };
};

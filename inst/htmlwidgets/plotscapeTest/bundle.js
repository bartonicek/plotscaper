var PLOTSCAPE = (() => {
    const defines = {};
    const entry = [null];
    function define(name, dependencies, factory) {
        defines[name] = { dependencies, factory };
        entry[0] = name;
    }
    define("require", ["exports"], (exports) => {
        Object.defineProperty(exports, "__cjsModule", { value: true });
        Object.defineProperty(exports, "default", { value: (name) => resolve(name) });
    });
    var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
        if (k2 === undefined) k2 = k;
        var desc = Object.getOwnPropertyDescriptor(m, k);
        if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
          desc = { enumerable: true, get: function() { return m[k]; } };
        }
        Object.defineProperty(o, k2, desc);
    }) : (function(o, m, k, k2) {
        if (k2 === undefined) k2 = k;
        o[k2] = m[k];
    }));
    var __exportStar = (this && this.__exportStar) || function(m, exports) {
        for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
    };
    define("handlers/Handler", ["require", "exports"], function (require, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Handler = void 0;
        class Handler {
            constructor() {
                this.registerCallbacks = (callbacks, when) => {
                    this.callbacks.push(...callbacks);
                    this.when.push(...when);
                    return this;
                };
                this.notifyAll = (when) => {
                    this.callbacks
                        .filter((e, i) => this.when[i] === when)
                        .forEach((callback) => callback());
                };
                this.callbacks = [];
                this.when = [];
            }
        }
        exports.Handler = Handler;
    });
    define("handlers/MarkerHandler", ["require", "exports", "handlers/Handler"], function (require, exports, Handler_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.MarkerHandler = void 0;
        class MarkerHandler extends Handler_js_1.Handler {
            constructor(n) {
                super();
                this.isOfMembership = (index, membership) => {
                    if (membership === 1)
                        return true;
                    const { current: curr, past } = this;
                    if (membership === 128) {
                        return curr[index] > 1 ? !!(curr[index] & 128) : !!(past[index] & 128);
                    }
                    return curr[index] > 1
                        ? curr[index] >= membership
                        : past[index] >= membership;
                };
                this.updateCurrent = (at, membership) => {
                    this.clearCurrent();
                    this.current.update(at, membership);
                    this.notifyAll("updateCurrent");
                };
                this.mergeCurrent = () => {
                    this.past.merge(this.current.asPersistent());
                    this.notifyAll("mergeCurrent");
                };
                this.clearCurrent = () => {
                    this.current = new MembershipArray([...this.past.asPersistent()]);
                };
                this.clearAll = () => {
                    this.current.clear();
                    this.past.clear();
                };
                this.n = n;
                this.current = new MembershipArray(n);
                this.past = new MembershipArray(n);
                this.callbacks = [];
                this.when = [];
            }
        }
        exports.MarkerHandler = MarkerHandler;
        class MembershipArray extends Uint8Array {
            constructor(arg) {
                super(arg);
                this.clear = () => this.fill(1);
                this.asPersistent = () => {
                    const res = new MembershipArray(this.length);
                    let i = this.length;
                    while (i--)
                        res[i] = this[i] & ~128;
                    return res;
                };
                this.asTransient = () => {
                    const res = new MembershipArray(this.length);
                    let i = this.length;
                    while (i--)
                        res[i] = this[i] & ~128;
                    return res;
                };
                this.merge = (arr) => {
                    let i = this.length;
                    while (i--) {
                        if (arr[i] === 1)
                            continue;
                        this[i] = arr[i];
                    }
                };
                this.update = (at, membership) => {
                    let i = at.length;
                    if (membership === 128) {
                        while (i--)
                            this[at[i]] = this[at[i]] | 128;
                        return;
                    }
                    while (i--)
                        this[at[i]] = membership;
                };
                if (typeof arg === "number")
                    this.fill(1);
            }
        }
    });
    define("functions", ["require", "exports"], function (require, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.timeExecution = exports.rectOverlap = exports.pointInRect = exports.uniqueRowIds = exports.uniqueRows = exports.arrTranspose = exports.arrEqual = exports.prettyBreaks = exports.accessIndexed = exports.accessUnpeel = exports.accessDeep = exports.throttle = exports.unique = exports.match = exports.which = exports.gatedMultiply = exports.quantile = exports.bin = exports.capitalize = exports.max = exports.min = exports.mean = exports.sum = exports.length = exports.identity = exports.isNumeric = void 0;
        const deeplyClone = (x) => {
            return JSON.parse(JSON.stringify(x));
        };
        const isNumeric = (x) => typeof x[0] === "number";
        exports.isNumeric = isNumeric;
        const identity = (x) => x;
        exports.identity = identity;
        const length = (x) => (x.length ? x.length : 0);
        exports.length = length;
        const sum = (x) => x.reduce((a, b) => a + b, 0);
        exports.sum = sum;
        const mean = (x) => x.length > 0 ? x.reduce((a, b) => a + b) / x.length : null;
        exports.mean = mean;
        const min = (x) => (x.length > 0 ? Math.min(...x) : null);
        exports.min = min;
        const max = (x) => (x.length > 0 ? Math.max(...x) : null);
        exports.max = max;
        const capitalize = (x) => {
            return typeof x === "string"
                ? x.charAt(0).toUpperCase() + x.slice(1)
                : x.map((e) => e.charAt(0).toUpperCase() + e.slice(1));
        };
        exports.capitalize = capitalize;
        const bin = (x, n = 5) => {
            const range = Math.max(...x) - Math.min(...x);
            const width = range / n;
            const breaks = Array.from(Array(n + 1), (e, i) => Math.min(...x) + i * width);
            const centroids = breaks.map((e, i) => (e + breaks[i - 1]) / 2);
            breaks.reverse();
            centroids.shift();
            return x
                .map((e) => breaks.findIndex((f) => e >= f))
                .map((e) => (e === 0 ? breaks.length - 2 : breaks.length - e - 1))
                .map((e) => centroids[e]);
        };
        exports.bin = bin;
        const quantile = (x, q) => {
            const sorted = x.sort((a, b) => a - b);
            if (typeof q === "number") {
                // For a single quantile
                const pos = q * (sorted.length - 1);
                const { lwr, uppr } = { lwr: Math.floor(pos), uppr: Math.ceil(pos) };
                return sorted[lwr] + (pos % 1) * (sorted[uppr] - sorted[lwr]);
            }
            else {
                // For multiple quantiles
                const pos = q.map((e) => e * (sorted.length - 1));
                const { lwr, uppr } = {
                    lwr: pos.map((e) => Math.floor(e)),
                    uppr: pos.map((e) => Math.ceil(e)),
                };
                return pos.map((e, i) => sorted[lwr[i]] + (e % 1) * (sorted[uppr[i]] - sorted[lwr[i]]));
            }
        };
        exports.quantile = quantile;
        const gatedMultiply = (a, b, limits) => {
            if (a * b < limits.min)
                return limits.min;
            if (a * b > limits.max)
                return limits.max;
            return a * b;
        };
        exports.gatedMultiply = gatedMultiply;
        const which = (x, value) => {
            return x.map((e, i) => (e === value ? i : NaN)).filter((e) => !isNaN(e));
        };
        exports.which = which;
        const match = (x, values) => {
            return x.map((e) => values.indexOf(e));
        };
        exports.match = match;
        const unique = (x) => {
            const uniqueArray = Array.from(new Set(x));
            return uniqueArray.length === 1 ? uniqueArray[0] : uniqueArray;
            //return x.filter((e, i) => x.indexOf(e) === i);    Slower
        };
        exports.unique = unique;
        const accessDeep = (obj, ...props) => {
            return props.reduce((a, b) => a && a[b], obj);
        };
        exports.accessDeep = accessDeep;
        const accessUnpeel = (obj, ...props) => {
            var _a;
            const destination = props.pop();
            let result;
            for (let i = props.length; i >= 0; i--) {
                result = (_a = accessDeep(obj, ...props, destination)) !== null && _a !== void 0 ? _a : null;
                if (result)
                    break;
                props.pop();
            }
            return result;
        };
        exports.accessUnpeel = accessUnpeel;
        const accessIndexed = (obj, index) => {
            // Deep-clone the object to retain structure
            const res = deeplyClone(obj);
            Object.keys(obj).forEach((e) => (res[e] = obj[e][index]));
            return res;
        };
        exports.accessIndexed = accessIndexed;
        const throttle = (fun, delay) => {
            let lastTime = 0;
            return (...args) => {
                const now = new Date().getTime();
                if (now - lastTime < delay)
                    return;
                lastTime = now;
                fun(...args);
            };
        };
        exports.throttle = throttle;
        // Function to construct "pretty" breaks, inspired by R's pretty()
        const prettyBreaks = (x, n = 4) => {
            const [min, max] = [Math.min(...x), Math.max(...x)];
            const range = max - min;
            const unitGross = range / n;
            const base = Math.floor(Math.log10(unitGross));
            const dists = [1, 2, 4, 5, 6, 8, 10].map((e) => Math.pow((e - unitGross / Math.pow(10, base)), 2));
            const unitNeat = Math.pow(10, base) * [1, 2, 4, 5, 6, 8, 10][dists.indexOf(Math.min(...dists))];
            const big = Math.abs(base) > 4;
            const minNeat = Math.round(min / unitNeat) * unitNeat;
            const maxNeat = Math.round(max / unitNeat) * unitNeat;
            const middle = Array.from(Array(Math.floor((maxNeat - minNeat) / unitNeat - 1)), (e, i) => minNeat + (i + 1) * unitNeat);
            // const middle = [];
            // let i = (maxNeat - minNeat) / unitNeat - 1;
            // while (i--) middle[i] = minNeat + (i + 1) * unitNeat;
            const breaks = [minNeat, ...middle, maxNeat].map((e) => parseFloat(e.toFixed(4)));
            return big ? breaks.map((e) => e.toExponential()) : breaks;
        };
        exports.prettyBreaks = prettyBreaks;
        // arrEqual: Checks if two arrays are deeply equal
        const arrEqual = (array1, array2) => {
            return (array1.length == array2.length && array1.every((e, i) => e === array2[i]));
        };
        exports.arrEqual = arrEqual;
        const arrTranspose = (data) => {
            return data[0].map((_, i) => data.map((row) => row[i]));
        };
        exports.arrTranspose = arrTranspose;
        // uniqueRows: Gets the unique rows & corresponding row ids of a dataframe
        // (stored as an array of arrays/list of columns).
        // Runs faster than a for loop, even though the rows are created twice
        const uniqueRows = (data) => {
            // Transpose dataframe from array of cols to array of rows & turn the rows into strings
            const stringDataT = data[0].map((_, i) => JSON.stringify(data.map((row) => row[i])));
            const stringValues = unique(stringDataT);
            const indices = stringValues.map((e) => stringDataT.flatMap((f, j) => (f === e ? j : [])));
            const values = indices.map((e) => {
                return data.map((f) => f[e[0]]);
            });
            return { values, indices };
        };
        exports.uniqueRows = uniqueRows;
        const uniqueRowIds = (data) => {
            // Transpose dataframe from array of cols to array of rows & turn the rows into strings
            const stringRows = data[0].map((_, i) => JSON.stringify(data.map((row) => row[i])));
            const uniqueStringRows = unique(stringRows);
            return stringRows.map((e) => uniqueStringRows.indexOf(e));
        };
        exports.uniqueRowIds = uniqueRowIds;
        const pointInRect = (point, // x, y
        rect // x0, x1, y0, y1
        ) => {
            return ((point[0] - rect[0][0]) * (point[0] - rect[1][0]) < 0 &&
                (point[1] - rect[0][1]) * (point[1] - rect[1][1]) < 0);
        };
        exports.pointInRect = pointInRect;
        const rectOverlap = (rect1, rect2) => {
            const [p1x, p1y] = [0, 1].map((e) => rect1.map((f) => f[e]));
            const [p2x, p2y] = [0, 1].map((e) => rect2.map((f) => f[e]));
            return !(Math.max(...p1x) < Math.min(...p2x) ||
                Math.min(...p1x) > Math.max(...p2x) ||
                Math.max(...p1y) < Math.min(...p2y) ||
                Math.min(...p1y) > Math.max(...p2y));
        };
        exports.rectOverlap = rectOverlap;
        const vecDiff = (x, y) => {
            return x.map((e, i) => e - y[i]);
        };
        // Function to test if point is inside polygon based on linear algebra.
        // Hopefuly works. If not, try implementing the following:
        // https://wrf.ecse.rpi.edu/Research/Short_Notes/pnpoly.html
        const insidePoly = (point, polygon, distance) => {
            const xmin = Math.min(...polygon.map((e) => e[0]));
            const ymin = Math.min(...polygon.map((e) => e[1]));
            const xmax = Math.max(...polygon.map((e) => e[0]));
            const ymax = Math.max(...polygon.map((e) => e[1]));
            if (point[0] < xmin ||
                point[0] > xmax ||
                point[1] < ymin ||
                point[1] > ymax) {
                return false;
            }
            const inds1 = Array.from(Array(polygon.length), (e, i) => i);
            const inds2 = Array.from(Array(polygon.length), (e, i) => i);
            inds2.shift();
            inds2.push(0);
            const sides = inds1.map((e, i) => vecDiff(polygon[inds2[i]], polygon[e]));
            const intersections = polygon.map((e, i) => {
                return [
                    (point[1] - e[1]) / sides[i][1],
                    ((point[1] - e[1]) / sides[i][1]) * sides[i][0] + e[0] - point[0],
                ];
            });
            const valid = intersections
                .map((e) => e[1])
                .filter((f) => f > 0 && f < distance);
            return valid.length % 2 === 1;
        };
        const timeExecution = (fun) => {
            const start = performance.now();
            fun();
            const end = performance.now();
            return end - start;
        };
        exports.timeExecution = timeExecution;
    });
    define("handlers/KeypressHandler", ["require", "exports", "functions", "handlers/Handler"], function (require, exports, funs, Handler_js_2) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.KeypressHandler = void 0;
        class KeypressHandler extends Handler_js_2.Handler {
            constructor() {
                super();
                this.keyPressed = (event) => {
                    if (this.pressing && !this.isRedrawKey)
                        return;
                    this.pressing = true;
                    if (this.validKeys.includes(event.code)) {
                        this.lastPressed = event.code;
                        this.currentlyPressed[this.validKeys.indexOf(event.code)] = true;
                        this.notifyAll("keyPressed");
                    }
                };
                this.keyReleased = (event) => {
                    this.pressing = false;
                    if (this.validKeys.includes(event.code)) {
                        this.currentlyPressed[this.validKeys.indexOf(event.code)] = false;
                        this.notifyAll("keyReleased");
                    }
                };
                this.isPressed = (key) => {
                    return this.currentlyPressed.filter((_, i) => this.validKeys[i] === key)[0];
                };
                this.callbacks = [];
                this.validKeys = [
                    "Equal",
                    "Minus",
                    "BracketLeft",
                    "BracketRight",
                    "ControlLeft",
                    "ShiftLeft",
                    "KeyR",
                    "Digit1",
                    "Digit2",
                    "Digit3",
                ];
                this.redrawKeys = ["Equal", "Minus", "BracketLeft", "BracketRight", "KeyR"];
                this.pressing = false;
                this.lastPressed = "";
                this.currentlyPressed = Array(this.validKeys.length).fill(false);
                this.actions = ["keydown", "keyup"];
                this.consequences = ["keyPressed", "keyReleased"];
                // Register key press/release behavior on the document body
                this.actions.forEach((action, i) => {
                    document.body.addEventListener(action, (event) => funs.throttle(this[this.consequences[i]](event), 100));
                });
            }
            get isRedrawKey() {
                return this.redrawKeys.includes(this.lastPressed);
            }
            get currentlyPressedKeys() {
                return this.validKeys.filter((_, i) => this.currentlyPressed[i]);
            }
        }
        exports.KeypressHandler = KeypressHandler;
    });
    define("handlers/StateHandler", ["require", "exports", "handlers/Handler"], function (require, exports, Handler_js_3) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.StateHandler = void 0;
        class StateHandler extends Handler_js_3.Handler {
            constructor() {
                super();
                this.activate = (id) => {
                    this.plotsActive[this.plotIds.indexOf(id)] = true;
                    this.plotContainers[this.plotIds.indexOf(id)].classList.add("active");
                };
                this.activateAll = () => {
                    this.plotsActive.fill(true);
                    this.plotContainers.forEach((e) => e.classList.add("active"));
                };
                this.deactivateAll = () => {
                    this.plotsActive.fill(false);
                    this.plotContainers.forEach((e) => e.classList.remove("active"));
                };
                this.isActive = (id) => {
                    return this.plotsActive[this.plotIds.indexOf(id)];
                };
                this.inState = (state) => {
                    const { keypressHandler, validStates, stateKeys } = this;
                    if (state === "none" && !keypressHandler.currentlyPressed.some((e) => e))
                        return true;
                    return keypressHandler.isPressed(stateKeys[validStates.indexOf(state)]);
                };
                this.plotIds = [];
                this.plotsActive = [];
                this.plotContainers = [];
                this.validStates = ["not", "or", "group1", "group2", "group3"];
                this.stateKeys = ["ControlLeft", "ShiftLeft", "Digit1", "Digit2", "Digit3"];
                this.membershipArray = [1, 128, 2, 3, 4];
            }
            get currentId() {
                var _a;
                const { stateKeys, keypressHandler } = this;
                return ((_a = stateKeys.flatMap((e, i) => keypressHandler.currentlyPressedKeys.includes(e) ? i : [])[0]) !== null && _a !== void 0 ? _a : -1);
            }
            get current() {
                return this.validStates[this.currentId];
            }
            get membership() {
                var _a;
                return (_a = this.membershipArray[this.currentId]) !== null && _a !== void 0 ? _a : 128;
            }
        }
        exports.StateHandler = StateHandler;
    });
    define("handlers/DragHandler", ["require", "exports", "functions", "handlers/Handler"], function (require, exports, funs, Handler_js_4) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.DragHandler = void 0;
        class DragHandler extends Handler_js_4.Handler {
            constructor(container) {
                super();
                this.startDrag = (event) => {
                    this.dragging = true;
                    this.start = [event.offsetX, event.offsetY];
                    this.notifyAll("startDrag");
                };
                this.whileDrag = (event) => {
                    const { dragging, notifyAll } = this;
                    if (dragging) {
                        this.end = [event.offsetX, event.offsetY];
                        const dist = Math.pow((this.start[0] - this.end[0]), 2) + Math.pow((this.start[1] - this.end[1]), 2);
                        if (dist > 50)
                            notifyAll("whileDrag");
                    }
                };
                this.endDrag = () => {
                    this.dragging = false;
                    this.notifyAll("endDrag");
                };
                this.container = container;
                this.dragging = false;
                this.start = [null, null];
                this.end = [null, null];
                this.actions = ["mousedown", "mousemove", "mouseup"];
                this.consequences = ["startDrag", "whileDrag", "endDrag"];
                // Register mouse behavior on the container, throttled to 50ms
                this.actions.forEach((action, i) => {
                    this.container.addEventListener(action, funs.throttle(this[this.consequences[i]], 50));
                });
            }
        }
        exports.DragHandler = DragHandler;
    });
    define("globalparameters", ["require", "exports"], function (require, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.globalParameters = void 0;
        exports.globalParameters = {
            bgCol: `#f2efde`,
            reps: {
                col: [`#cccccc`, `#1b9e77`, `#d95f02`, `#7570b3`, `#ffffffCC`],
                strokeCol: [null, null, null, null, `#000000`],
                strokeWidth: [1, 1, 1, 1, 1],
                radius: [5, 5, 5, 5, 5],
            },
        };
    });
    define("plot/GraphicLayer", ["require", "exports", "globalparameters"], function (require, exports, globalparameters_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.GraphicLayer = void 0;
        class GraphicLayer {
            constructor(globals, dimensions) {
                this.resize = () => {
                    this.canvas.style.width = `${this.width}px`;
                    this.canvas.style.height = `${this.height}px`;
                    this.canvas.width = Math.ceil(this.width * this.scaleFactor);
                    this.canvas.height = Math.ceil(this.height * this.scaleFactor);
                    this.context.scale(this.scaleFactor, this.scaleFactor);
                };
                this.dropMissing = (...vectors) => {
                    let missingIndices = [...vectors].flatMap((vector) => vector
                        .flatMap((value, index) => (value === null ? index : []))
                        .sort((a, b) => a - b));
                    missingIndices = Array.from(new Set(missingIndices));
                    return [...vectors].map((vector) => vector.flatMap((value, index) => missingIndices.indexOf(index) === -1 ? value : []));
                };
                this.toAlpha = (col, alpha) => {
                    if (alpha === 1)
                        return col;
                    const alpha16 = Math.floor(alpha * 255)
                        .toString(16)
                        .toUpperCase();
                    const colString = alpha16.length < 2 ? col + "0" + alpha16 : col + alpha16;
                    return colString;
                };
                this.drawClear = () => {
                    const context = this.context;
                    context.save();
                    context.clearRect(0, 0, this.width, this.height);
                    context.restore();
                };
                this.drawBackground = () => {
                    const context = this.context;
                    context.save();
                    context.fillStyle = globalparameters_js_1.globalParameters.bgCol;
                    context.fillRect(0, 0, this.width, this.height);
                    context.restore();
                };
                this.drawBarsV = (x, y, y0, pars = {
                    col: globalparameters_js_1.globalParameters.reps.col[0],
                    strokeCol: null,
                    strokeWidth: null,
                    alpha: 1,
                    width: 50,
                }) => {
                    const [xs, ys] = this.dropMissing(x, y);
                    const { col, strokeCol, strokeWidth, alpha, width } = pars;
                    const context = this.context;
                    context.save();
                    context.fillStyle = this.toAlpha(col, alpha);
                    context.strokeStyle = strokeCol;
                    context.lineWidth = strokeWidth;
                    xs.forEach((e, i) => {
                        col ? context.fillRect(e - width / 2, ys[i], width, y0 - ys[i]) : null;
                        strokeCol
                            ? context.strokeRect(e - width / 2, ys[i], width, y0 - ys[i])
                            : null;
                    });
                    context.restore();
                };
                this.drawPoints = (x, y, pars = {
                    col: globalparameters_js_1.globalParameters.reps.col[0],
                    radius: 5,
                    strokeCol: null,
                    strokeWidth: null,
                    alpha: 1,
                }) => {
                    const context = this.context;
                    const { col, radius, strokeCol, strokeWidth, alpha } = pars;
                    const rs = typeof radius === "number"
                        ? Array.from(Array(x.length), (e) => radius)
                        : radius;
                    context.save();
                    context.fillStyle = this.toAlpha(col, alpha);
                    context.strokeStyle = strokeCol;
                    context.lineWidth = strokeWidth;
                    x.forEach((e, i) => {
                        context.beginPath();
                        context.arc(e, y[i], rs[i] / 2, 0, Math.PI * 2);
                        strokeCol ? context.stroke() : null;
                        col ? context.fill() : null;
                    });
                    context.restore();
                };
                this.drawRectsHW = (x, y, h, w, pars = {
                    col: globalparameters_js_1.globalParameters.reps.col[0],
                    strokeCol: null,
                    strokeWidth: null,
                    alpha: 1,
                }) => {
                    const context = this.context;
                    const { col, strokeCol, strokeWidth, alpha } = pars;
                    context.save();
                    context.fillStyle = this.toAlpha(col, alpha);
                    context.strokeStyle = strokeCol;
                    context.lineWidth = strokeWidth;
                    x.forEach((e, i) => {
                        col ? context.fillRect(e - w[i] / 2, y[i] - h[i] / 2, h[i], w[i]) : null;
                        strokeCol
                            ? context.strokeRect(e - w[i] / 2, y[i] - h[i] / 2, h[i], w[i])
                            : null;
                    });
                    context.restore();
                };
                this.drawLine = (x, y, col = "black") => {
                    const context = this.context;
                    context.save();
                    context.beginPath();
                    context.strokeStyle = col;
                    context.moveTo(x[0], y[0]);
                    x.shift();
                    y.shift();
                    x.forEach((e, i) => {
                        context.lineTo(e, y[i]);
                    });
                    context.stroke();
                    context.restore();
                };
                this.drawText = (x, y, labels, size = 20, rotate) => {
                    const context = this.context;
                    context.save();
                    context.font = `${size}px Times New Roman`;
                    x.forEach((e, i) => {
                        context.translate(e, y[i]);
                        if (rotate)
                            context.rotate((rotate / 360) * Math.PI * 2);
                        context.fillText(labels[i], 0, 0);
                        context.translate(-e, -y[i]);
                    });
                    context.restore();
                };
                this.drawDim = (col = "rgba(120, 120, 120, 0.1)") => {
                    const context = this.context;
                    context.fillStyle = col;
                    context.fillRect(0, 0, this.width, this.height);
                };
                this.drawWindow = (start, end, stroke = "rgba(0, 0, 0, 0.25)") => {
                    const context = this.context;
                    context.save();
                    context.strokeStyle = stroke;
                    context.setLineDash([5, 5]);
                    context.clearRect(start[0], start[1], end[0] - start[0], end[1] - start[1]);
                    // context.strokeRect(
                    //   start[0],
                    //   start[1],
                    //   end[0] - start[0],
                    //   end[1] - start[1]
                    // );
                    context.restore();
                };
                this.globals = globals;
                this.dimensions = dimensions;
                this.canvas = document.createElement("canvas");
                this.context = this.canvas.getContext("2d");
                this.backgroundColour = globalparameters_js_1.globalParameters.bgCol;
                this.resize();
            }
            get width() {
                if (this.dimensions)
                    return this.dimensions.width;
                return this.globals.plotWidth;
            }
            get height() {
                if (this.dimensions)
                    return this.dimensions.height;
                return this.globals.plotHeight;
            }
            get scaleFactor() {
                return this.globals.scaleFactor;
            }
        }
        exports.GraphicLayer = GraphicLayer;
    });
    define("DataFrame", ["require", "exports"], function (require, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.DataFrame = void 0;
        class DataFrame {
            constructor(data) {
                Object.keys(data).forEach((e) => (this[e] = data[e]));
            }
            get _indicator() {
                return Array(this[Object.keys(this)[0]].length).fill(1);
            }
        }
        exports.DataFrame = DataFrame;
    });
    define("wrangler/Cast", ["require", "exports", "functions"], function (require, exports, funs) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Cast = void 0;
        class Cast {
            constructor(vector) {
                // No argument: default split, across all memberships
                this.getSplitOf = (membership) => {
                    const { acrossVec, indices, uniqueIndices, marker } = this;
                    const res = Array.from(Array(uniqueIndices.length), (e) => []);
                    let i = indices.length;
                    while (i--) {
                        if (!membership || marker.isOfMembership(i, membership)) {
                            res[indices[i]].push(acrossVec[i]);
                        }
                    }
                    return res;
                };
                this.extract = (membership = 1) => {
                    var _a;
                    const { marker, allUnique, withinFun, withinArgs, acrossVec, getSplitOf } = this;
                    if (membership) {
                        // Members + no split + across trans.
                        if (allUnique) {
                            return ((_a = acrossVec.filter((_, i) => marker.isOfMembership(i, membership))) !== null && _a !== void 0 ? _a : []);
                        }
                        // Members + split + across trans. + within trans.
                        return getSplitOf(membership)
                            .filter((e) => e.length > 0)
                            .flatMap((e) => withinFun(e, ...withinArgs));
                    }
                    // All + no split + across trans. only
                    if (allUnique)
                        return acrossVec;
                    // All + split + across trans. + within trans.
                    return getSplitOf()
                        .filter((e) => e.length > 0)
                        .flatMap((e) => withinFun(e, ...withinArgs));
                };
                this.registerAcross = (fun, ...args) => {
                    this.acrossFun = fun;
                    this.acrossArgs = args;
                    return this;
                };
                this.registerWithin = (fun, ...args) => {
                    this.withinFun = fun;
                    this.withinArgs = args;
                    return this;
                };
                this.vector = vector;
                this.marker = null;
                this.indices = null;
                this.allUnique = false;
                this.acrossFun = funs.identity;
                this.acrossArgs = [];
                this.withinFun = funs.identity;
                this.withinArgs = [];
            }
            get uniqueIndices() {
                return Array.from(new Set(this.indices));
            }
            get acrossVec() {
                return this.acrossFun(this.vector, ...this.acrossArgs);
            }
            get defaultSplit() {
                const { acrossVec, indices, uniqueIndices } = this;
                // Split vector array into sub-arrays based on indices
                const res = uniqueIndices.map((uniqueIndex) => indices.flatMap((index, i) => (index === uniqueIndex ? acrossVec[i] : [])));
                return res;
            }
        }
        exports.Cast = Cast;
    });
    define("wrangler/Wrangler", ["require", "exports", "functions", "wrangler/Cast"], function (require, exports, funs, Cast_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Wrangler = void 0;
        class Wrangler {
            constructor(data, mapping, marker) {
                this.getVariable = (mapping) => {
                    return this.data[this.mapping.get(mapping)];
                };
                this.extractAsIs = (...mappings) => {
                    this.indices = Array.from(Array(this.marker.n), (e, i) => i);
                    mappings.forEach((mapping) => {
                        this[mapping] = new Cast_js_1.Cast(this.getVariable(mapping));
                        this[mapping].marker = this.marker;
                        this[mapping].allUnique = true;
                    });
                    return this;
                };
                this.splitBy = (...mappings) => {
                    mappings.forEach((mapping, i) => {
                        this.by.add(mapping);
                        this[mapping] = new Cast_js_1.Cast(this.getVariable(mapping));
                        this[mapping].marker = this.marker;
                    });
                    return this;
                };
                this.splitWhat = (...mappings) => {
                    mappings.forEach((mapping) => {
                        this.what.add(mapping);
                        this[mapping] = new Cast_js_1.Cast(this.getVariable(mapping));
                        this[mapping].marker = this.marker;
                    });
                    return this;
                };
                this.doAcross = (target, fun, ...args) => {
                    if (target === "by" || target === "what") {
                        Array.from(this[target]).forEach((mapping) => {
                            this[mapping].registerAcross(fun, ...args);
                        });
                        return this;
                    }
                    this[target].registerAcross(fun, ...args);
                    return this;
                };
                this.doWithin = (target, fun, ...args) => {
                    if (target === "by" || target === "what") {
                        Array.from(this[target]).forEach((mapping) => {
                            this[mapping].registerWithin(fun, ...args);
                        });
                        return this;
                    }
                    this[target].registerWithin(fun, ...args);
                    return this;
                };
                this.assignIndices = () => {
                    const { what, by } = this;
                    const splittingVars = Array.from(by).map((e) => this[e].acrossVec);
                    this.indices = funs.uniqueRowIds(splittingVars);
                    Array.from([...by, ...what]).map((e) => {
                        this[e].indices = this.indices;
                    });
                    return this;
                };
                this.data = data;
                this.mapping = mapping;
                this.marker = marker;
                this.indices = [];
                this.by = new Set();
                this.what = new Set();
            }
        }
        exports.Wrangler = Wrangler;
    });
    define("representations/Representation", ["require", "exports", "datastructures", "functions", "globalparameters"], function (require, exports, dtstr, funs, globalparameters_js_2) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Representation = void 0;
        class Representation {
            constructor(wrangler) {
                this.getMapping = (mapping, membership = 1) => {
                    var _a, _b;
                    let res = (_a = this.wrangler[mapping]) === null || _a === void 0 ? void 0 : _a.extract(membership);
                    res = (_b = this.scales[mapping]) === null || _b === void 0 ? void 0 : _b.dataToPlot(res);
                    return res !== null && res !== void 0 ? res : [];
                };
                this.getPars = (membership) => {
                    if (membership === 128)
                        return this.pars[this.pars.length - 1];
                    return this.pars[(membership & ~128) - 1];
                };
                this.drawBase = (context) => { };
                this.drawHighlight = (context, selectedPoints) => { };
                this.registerScales = (scales) => {
                    this.scales = scales;
                    return this;
                };
                this.defaultize = () => {
                    this.alphaMultiplier = 1;
                    this.sizeMultiplier = 1;
                };
                // Checks which bounding rects overlap with a rectangular selection region
                //E.g. [[0, 0], [Width, Height]] should include all bound. rects
                this.inSelection = (selectionRect) => {
                    const { wrangler, boundingRects } = this;
                    const selectedReps = boundingRects.map((rect) => {
                        return funs.rectOverlap(selectionRect, rect);
                    });
                    const selectedDatapoints = wrangler.indices.flatMap((e, i) => {
                        return selectedReps[e] ? i : [];
                    });
                    return selectedDatapoints;
                };
                this.atClick = (clickPoint) => {
                    const { wrangler, boundingRects } = this;
                    const selectedReps = boundingRects.map((rect) => {
                        return funs.pointInRect(clickPoint, rect);
                    });
                    const selectedDatapoints = wrangler.indices.flatMap((e, i) => {
                        return selectedReps[e] ? i : [];
                    });
                    return selectedDatapoints;
                };
                // Handle generic keypress actions
                this.onKeypress = (key) => {
                    const { sizeMultiplier, sizeLimits, alphaMultiplier, alphaLimits } = this;
                    if (key === "KeyR")
                        this.defaultize();
                    if (key === "Minus" && sizeMultiplier) {
                        this.sizeMultiplier = funs.gatedMultiply(sizeMultiplier, 0.8, sizeLimits);
                    }
                    if (key === "Equal" && sizeMultiplier && sizeMultiplier < sizeLimits.max) {
                        this.sizeMultiplier = funs.gatedMultiply(sizeMultiplier, 1.2, sizeLimits);
                    }
                    if (key === "BracketLeft" && alphaMultiplier) {
                        this.alphaMultiplier = funs.gatedMultiply(alphaMultiplier, 0.8, alphaLimits);
                    }
                    if (key === "BracketRight" && alphaMultiplier)
                        this.alphaMultiplier = funs.gatedMultiply(alphaMultiplier, 1.2, alphaLimits);
                };
                this.wrangler = wrangler;
                this.pars = dtstr.validMembershipArray.map((e) => {
                    const p = globalparameters_js_2.globalParameters.reps;
                    if (e === 128)
                        return funs.accessIndexed(p, p.col.length - 1);
                    return funs.accessIndexed(p, (e & ~128) - 1);
                });
                this.sizeMultiplier = 1;
                this.alphaMultiplier = 1;
                this.sizeLimits = {
                    min: 0.001,
                    max: 10,
                };
                this.alphaLimits = {
                    min: 0.01,
                    max: 1,
                };
            }
            get boundingRects() {
                return [];
            }
        }
        exports.Representation = Representation;
    });
    define("representations/Bars", ["require", "exports", "datastructures", "representations/Representation"], function (require, exports, dtstr, Representation_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Bars = void 0;
        class Bars extends Representation_js_1.Representation {
            constructor(wrangler, widthMultiplier) {
                super(wrangler);
                this.defaultize = () => {
                    this.sizeMultiplier = this.widthMultiplier;
                    this.alphaMultiplier = 1;
                };
                this.getMappings = (membership) => {
                    const mappings = ["x", "y"];
                    return mappings.map((e) => this.getMapping(e, membership));
                };
                this.drawBase = (context) => {
                    const [x, y] = this.getMappings(0);
                    const { y0, width, alphaMultiplier } = this;
                    const { col, strokeCol, strokeWidth } = this.pars[0];
                    const pars = { col, strokeCol, strokeWidth, alpha: alphaMultiplier, width };
                    context.drawBarsV(x, y, y0, pars);
                };
                this.drawHighlight = (context) => {
                    dtstr.highlightMembershipArray.forEach((e) => {
                        const [x, y] = this.getMappings(e);
                        // console.log(e);
                        // console.log(y);
                        if (!(x.length > 0))
                            return;
                        const { y0, width } = this;
                        const { col, strokeCol, strokeWidth } = this.getPars(e);
                        const pars = { col, strokeCol, strokeWidth, alpha: 1, width };
                        context.drawBarsV(x, y, y0, pars);
                    });
                };
                this.widthMultiplier = widthMultiplier;
                this.sizeMultiplier = widthMultiplier;
                this.sizeLimits = { min: 0.01, max: 1 };
                this.alphaMultiplier = 1;
            }
            get y0() {
                return this.scales.y.plotMin;
            }
            get width() {
                return (this.sizeMultiplier *
                    (this.getMapping("x").sort()[1] - this.getMapping("x").sort()[0]));
            }
            get boundingRects() {
                const [x, y] = this.getMappings();
                const [wh, y0] = [this.width / 2, this.scales.y.plotMin];
                return x.map((xi, i) => [
                    [xi - wh, y0],
                    [xi + wh, y[i]],
                ]);
            }
        }
        exports.Bars = Bars;
    });
    define("representations/Points", ["require", "exports", "datastructures", "representations/Representation"], function (require, exports, dtstr, Representation_js_2) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Points = void 0;
        class Points extends Representation_js_2.Representation {
            constructor(wrangler) {
                super(wrangler);
                this.getMappings = (membership) => {
                    const mappings = ["x", "y", "size"];
                    let [x, y, size] = mappings.map((e) => this.getMapping(e, membership));
                    const radius = this.getPars(membership).radius;
                    size =
                        size.length > 0
                            ? size.map((e) => radius * e * this.sizeMultiplier)
                            : Array.from(Array(x.length), (e) => radius * this.sizeMultiplier);
                    return [x, y, size];
                };
                this.drawBase = (context) => {
                    const [x, y, size] = this.getMappings(1);
                    const { col, strokeCol, strokeWidth } = this.getPars(1);
                    const pars = {
                        col,
                        radius: size,
                        strokeCol,
                        strokeWidth,
                        alpha: this.alphaMultiplier,
                    };
                    context.drawPoints(x, y, pars);
                };
                this.drawHighlight = (context) => {
                    dtstr.highlightMembershipArray.forEach((e) => {
                        const [x, y, size] = this.getMappings(e);
                        if (!(x.length > 0))
                            return;
                        const { col, strokeCol, strokeWidth } = this.getPars(e);
                        const pars = {
                            col,
                            radius: size,
                            strokeCol,
                            strokeWidth,
                            alpha: 1,
                        };
                        context.drawPoints(x, y, pars);
                    });
                };
            }
            get boundingRects() {
                const [x, y, size] = this.getMappings(1);
                const c = 1 / Math.sqrt(2);
                return x.map((xi, i) => [
                    [xi - c * size[i], y[i] - c * size[i]],
                    [xi + c * size[i], y[i] + c * size[i]],
                ]);
            }
        }
        exports.Points = Points;
    });
    define("representations/Squares", ["require", "exports", "representations/Representation", "datastructures"], function (require, exports, Representation_js_3, dtstr) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Squares = void 0;
        class Squares extends Representation_js_3.Representation {
            constructor(wrangler) {
                super(wrangler);
                this.getMappings = (membership = 1) => {
                    const mappings = ["x", "y", "size"];
                    let [x, y, size] = mappings.map((e) => this.getMapping(e, membership));
                    const radius = this.getPars(membership).radius;
                    size =
                        size.length > 0
                            ? size.map((e) => radius * e * this.sizeMultiplier)
                            : Array.from(Array(x.length), (e) => radius * this.sizeMultiplier);
                    return [x, y, size];
                };
                this.drawBase = (context) => {
                    const [x, y, size] = this.getMappings(1);
                    const { col, strokeCol, strokeWidth } = this.pars[0];
                    const pars = { col, strokeCol, strokeWidth, alpha: this.alphaMultiplier };
                    context.drawRectsHW(x, y, size, size, pars);
                };
                this.drawHighlight = (context) => {
                    dtstr.highlightMembershipArray.forEach((e) => {
                        const [x, y, size] = this.getMappings(e);
                        if (!x)
                            return;
                        const { col, strokeCol, strokeWidth } = this.getPars(e);
                        const pars = { col, strokeCol, strokeWidth, alpha: 1 };
                        context.drawRectsHW(x, y, size, size, pars);
                    });
                };
            }
            get boundingRects() {
                const [x, y, size] = this.getMappings();
                return x.map((xi, i) => [
                    [xi - size[i] / 2, y[i] - size[i] / 2],
                    [xi + size[i] / 2, y[i] + size[i] / 2],
                ]);
            }
        }
        exports.Squares = Squares;
    });
    define("representations/representations", ["require", "exports", "representations/Representation", "representations/Bars", "representations/Points", "representations/Squares"], function (require, exports, Representation_js_4, Bars_js_1, Points_js_1, Squares_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        __exportStar(Representation_js_4, exports);
        __exportStar(Bars_js_1, exports);
        __exportStar(Points_js_1, exports);
        __exportStar(Squares_js_1, exports);
    });
    define("scales/Scale", ["require", "exports"], function (require, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Scale = void 0;
        class Scale {
            constructor(length, direction = 1, expand = 0.1) {
                this.setLength = (length) => {
                    this.lengthOriginal = length;
                    this.offsetOriginal = this.direction === -1 ? length : 0;
                };
                this.registerData = (data) => {
                    this.data = data;
                    return this;
                };
                this.pctToUnits = (pct) => {
                    const { length, offset, direction } = this;
                    return typeof pct === "number"
                        ? offset + direction * length * pct
                        : pct.map((e) => offset + direction * length * e);
                };
                this.unitsToPct = (units) => {
                    const { length } = this;
                    return typeof units === "number"
                        ? units / length
                        : units.map((e) => e / length);
                };
                this.dataToPlot = (data) => { };
                this.lengthOriginal = length;
                this.offsetOriginal = this.direction === -1 ? length : 0;
                this.span = 1;
                this.direction = direction;
                this.expand = expand;
            }
            get length() {
                return this.lengthOriginal * this.span;
            }
            get offset() {
                return this.offsetOriginal;
            }
        }
        exports.Scale = Scale;
    });
    define("scales/ScaleContinuous", ["require", "exports", "scales/Scale"], function (require, exports, Scale_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.ScaleContinuous = void 0;
        class ScaleContinuous extends Scale_js_1.Scale {
            constructor(length, direction = 1, zero = false, expand = 0.1) {
                super(length, direction, expand);
                this.data = [];
                this.registerData = (data) => {
                    this.data = this.zero ? [].concat([0], data) : data;
                    return this;
                };
                this.inRange = (x) => {
                    return x >= this.dataMin && x <= this.dataMax;
                };
                this.pctToData = (pct) => {
                    const { dataMin, range } = this;
                    return typeof pct === "number"
                        ? dataMin + pct * range
                        : pct.map((e) => dataMin + e * range);
                };
                this.dataToPct = (data) => {
                    const { dataMin, range } = this;
                    return typeof data === "number"
                        ? (data - dataMin) / range
                        : data.map((e) => (e - dataMin) / range);
                };
                this.dataToUnits = (data) => {
                    const { dataMin, length, offset, direction, range } = this;
                    return typeof data === "number"
                        ? offset + (direction * length * (data - dataMin)) / range
                        : data.map((e) => offset + direction * length * ((e - dataMin) / range));
                };
                this.unitsToData = (units) => {
                    const { dataMin, length, offset, direction, range } = this;
                    return typeof units === "number"
                        ? dataMin + (direction * range * (units - offset)) / length
                        : units.map((e) => dataMin + direction * range * ((e - offset) / length));
                };
                this.zero = zero;
            }
            get dataMin() {
                const { data, expand } = this;
                return this.zero
                    ? 0
                    : Math.min(...data) - expand * (Math.max(...data) - Math.min(...data));
            }
            get dataMax() {
                const { data, expand } = this;
                return Math.max(...data) + expand * (Math.max(...data) - Math.min(...data));
            }
            get range() {
                return this.dataMax - this.dataMin;
            }
        }
        exports.ScaleContinuous = ScaleContinuous;
    });
    define("scales/AreaScaleContinuous", ["require", "exports", "scales/ScaleContinuous"], function (require, exports, ScaleContinuous_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.AreaScaleContinuous = void 0;
        class AreaScaleContinuous extends ScaleContinuous_js_1.ScaleContinuous {
            constructor(length, direction = 1, zero = false) {
                super(length, direction, zero);
                this.dataToPlot = (data) => {
                    const res = this.dataToUnits(data);
                    return typeof res === "number"
                        ? Math.sqrt(res)
                        : res.map((e) => Math.sqrt(e));
                };
            }
            get dataMin() {
                return 0;
            }
        }
        exports.AreaScaleContinuous = AreaScaleContinuous;
    });
    define("scales/ScaleDiscrete", ["require", "exports", "scales/Scale"], function (require, exports, Scale_js_2) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.ScaleDiscrete = void 0;
        class ScaleDiscrete extends Scale_js_2.Scale {
            constructor(length, direction = 1, expand = 0.1) {
                super(length, direction, expand);
                this.toString = (x) => {
                    if (typeof x === "string" || typeof x[0] === "string")
                        return x;
                    return x.length ? x.map((e) => `${e}`) : `${x}`;
                };
                this.registerData = (data) => {
                    this.data = data;
                    const arr = Array.from(new Set([...data]));
                    this.values =
                        typeof arr[0] === "number"
                            ? arr.sort((a, b) => a - b)
                            : arr.sort();
                    this.positions = Array.from(Array(this.values.length), (e, i) => (i + 1) / (this.values.length + 1));
                    return this;
                };
                this.dataToUnits = (x) => {
                    const { values, length, direction, positions, offset } = this;
                    const xString = this.toString(x);
                    const valuesString = this.toString(values);
                    if (typeof xString === "string") {
                        return valuesString.indexOf(xString) !== -1
                            ? offset + direction * length * positions[valuesString.indexOf(xString)]
                            : null;
                    }
                    return xString.map((e) => valuesString.indexOf(e) !== -1
                        ? offset + direction * length * positions[valuesString.indexOf(e)]
                        : null);
                };
                this.values = [];
            }
        }
        exports.ScaleDiscrete = ScaleDiscrete;
    });
    define("scales/XYScaleDiscrete", ["require", "exports", "scales/ScaleDiscrete"], function (require, exports, ScaleDiscrete_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.XYScaleDiscrete = void 0;
        class XYScaleDiscrete extends ScaleDiscrete_js_1.ScaleDiscrete {
            constructor(length, direction = 1, expand = 0.1, margins = { lower: 0.2, upper: 0.1 }) {
                super(length, direction, expand);
                this.dataToPlot = (data) => {
                    return this.dataToUnits(data);
                };
                this.pctToPlot = (pct) => {
                    return this.pctToUnits(pct);
                };
                this.plotToPct = (units) => {
                    return this.unitsToPct(units);
                };
                this.margins = margins;
                this.span = 1 - margins.lower - margins.upper;
                // Shift & shrink the scale by the plot margins
                // this.offset =
                //   this.offset + this.direction * this.length * this.margins.lower;
                // this.length = (1 - this.margins.lower - this.margins.upper) * this.length;
            }
            get offset() {
                return (this.offsetOriginal +
                    this.direction * this.lengthOriginal * this.margins.lower);
            }
            get plotMin() {
                return this.pctToUnits(0);
            }
            get plotMax() {
                return this.pctToUnits(1);
            }
        }
        exports.XYScaleDiscrete = XYScaleDiscrete;
    });
    define("scales/XYScaleContinuous", ["require", "exports", "scales/ScaleContinuous"], function (require, exports, ScaleContinuous_js_2) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.XYScaleContinuous = void 0;
        class XYScaleContinuous extends ScaleContinuous_js_2.ScaleContinuous {
            constructor(length, direction = 1, zero = false, expand = 0.1, margins = { lower: 0.2, upper: 0.1 }) {
                super(length, direction, zero, expand);
                this.dataToPlot = (data) => {
                    return this.dataToUnits(data);
                };
                this.plotToData = (units) => {
                    return this.unitsToData(units);
                };
                this.pctToPlot = (pct) => {
                    return this.pctToUnits(pct);
                };
                this.plotToPct = (units) => {
                    return this.unitsToPct(units);
                };
                this.margins = margins;
                this.span = 1 - margins.lower - margins.upper;
                // Shift & shrink the scale by the plot margins
                // this.offset =
                //   this.offset + this.direction * this.length * this.margins.lower;
                // this.length = (1 - this.margins.lower - this.margins.upper) * this.length;
            }
            get offset() {
                return (this.offsetOriginal +
                    this.direction * this.lengthOriginal * this.margins.lower);
            }
            get plotMin() {
                return this.pctToUnits(0);
            }
            get plotMax() {
                return this.pctToUnits(1);
            }
        }
        exports.XYScaleContinuous = XYScaleContinuous;
    });
    define("scales/scales", ["require", "exports", "scales/Scale", "scales/AreaScaleContinuous", "scales/XYScaleDiscrete", "scales/XYScaleContinuous"], function (require, exports, Scale_js_3, AreaScaleContinuous_js_1, XYScaleDiscrete_js_1, XYScaleContinuous_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        __exportStar(Scale_js_3, exports);
        __exportStar(AreaScaleContinuous_js_1, exports);
        __exportStar(XYScaleDiscrete_js_1, exports);
        __exportStar(XYScaleContinuous_js_1, exports);
    });
    define("auxiliaries/Auxiliary", ["require", "exports"], function (require, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Auxiliary = void 0;
        class Auxiliary {
            constructor() {
                this.registerScales = (scales) => {
                    this.scales = scales;
                    return this;
                };
                this.draw = (context, ...args) => { };
                this.drawBase = (context, ...args) => { };
                this.drawUser = (context, handler, ...args) => { };
            }
        }
        exports.Auxiliary = Auxiliary;
    });
    define("auxiliaries/AxisBox", ["require", "exports", "auxiliaries/Auxiliary"], function (require, exports, Auxiliary_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.AxisBox = void 0;
        class AxisBox extends Auxiliary_js_1.Auxiliary {
            constructor() {
                super(...arguments);
                this.draw = (context) => {
                    const x0 = this.scales.x.plotMin;
                    const x1 = this.scales.x.plotMax;
                    const y0 = this.scales.y.plotMin;
                    const y1 = this.scales.y.plotMax;
                    context.drawLine([x0, x1], [y0, y0]);
                    context.drawLine([x0, x0], [y0, y1]);
                };
                this.drawBase = (context) => {
                    this.draw(context);
                };
                this.drawHighlight = (context) => {
                    this.draw(context);
                };
            }
        }
        exports.AxisBox = AxisBox;
    });
    define("auxiliaries/AxisText", ["require", "exports", "auxiliaries/Auxiliary", "functions"], function (require, exports, Auxiliary_js_2, funs) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.AxisText = void 0;
        class AxisText extends Auxiliary_js_2.Auxiliary {
            constructor(along, nbreaks) {
                super();
                this.getLabelMetrics = (context) => {
                    return this.labels.map((label) => context.context.measureText(label));
                };
                this.draw = (context) => {
                    const { scales, along, other, breaks } = this;
                    const size = Math.min(...[along, other].map((e) => 0.3 * scales[e].margins.lower * scales[e].length));
                    const intercepts = Array.from(Array(breaks.length), (e) => scales[other].plotMin + (along === "x" ? 5 : -5));
                    const coords = { x: null, y: null };
                    coords[along] = breaks;
                    coords[other] = intercepts;
                    if (along === "x") {
                        context.context.textBaseline = "top";
                        context.context.textAlign = "center";
                    }
                    if (along === "y") {
                        context.context.textBaseline = "middle";
                        context.context.textAlign = "right";
                    }
                    //    context.context.textAlign = along === "x" ? "center" : "right";
                    context.drawText(coords.x, coords.y, this.labels, size);
                };
                this.drawBase = (context) => {
                    this.draw(context);
                };
                this.along = along;
                this.other = along === "x" ? "y" : "x";
                this.nbreaks = nbreaks !== null && nbreaks !== void 0 ? nbreaks : 4;
            }
            get dataBreaks() {
                var _a;
                return ((_a = this.scales[this.along].values) !== null && _a !== void 0 ? _a : funs.prettyBreaks(this.scales[this.along].data, this.nbreaks));
            }
            get breaks() {
                return this.scales[this.along].dataToPlot(this.dataBreaks);
            }
            get labels() {
                return this.scales[this.along].values
                    ? this.scales[this.along].values.map((e) => e.toString())
                    : this.dataBreaks.map((e) => e.toString());
            }
        }
        exports.AxisText = AxisText;
    });
    define("auxiliaries/AxisTitle", ["require", "exports", "auxiliaries/Auxiliary"], function (require, exports, Auxiliary_js_3) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.AxisTitle = void 0;
        class AxisTitle extends Auxiliary_js_3.Auxiliary {
            constructor(along, label) {
                super();
                this.getLabelMetrics = (context) => {
                    return context.context.measureText(this.label);
                };
                this.draw = (context) => {
                    if (this.label === "_indicator")
                        return;
                    const { scales, along, other } = this;
                    const size = Math.min(...[along, other].map((e) => 0.4 * scales[e].margins.lower * scales[e].length));
                    const coords = { x: null, y: null };
                    coords[along] = scales[along].pctToPlot(0.5);
                    coords[other] =
                        scales[other].pctToPlot(0) +
                            (along === "x" ? 1 : -1) *
                                0.85 *
                                scales[other].margins.lower *
                                scales[other].length;
                    const rot = this.along === "x" ? 0 : 270;
                    context.context.textAlign = "center";
                    context.context.textBaseline = "middle";
                    context.drawText([coords.x], [coords.y], [this.label], size, rot);
                };
                this.drawBase = (context) => {
                    this.draw(context);
                };
                this.along = along;
                this.other = along === "x" ? "y" : "x";
                this.label = label;
            }
        }
        exports.AxisTitle = AxisTitle;
    });
    define("auxiliaries/HighlightRects", ["require", "exports", "auxiliaries/Auxiliary"], function (require, exports, Auxiliary_js_4) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.HighlightRects = void 0;
        class HighlightRects extends Auxiliary_js_4.Auxiliary {
            constructor(handlers) {
                super();
                this.updateCurrentOrigin = (point) => {
                    this.current[0] = point;
                };
                this.updateCurrentEndpoint = (point) => {
                    this.current[1] = point;
                };
                this.updateLast = () => {
                    this.last = [this.current[0], this.current[1]];
                    this.empty = false;
                };
                this.pushLastToPast = () => {
                    this.past.push([this.last[0], this.last[1]]);
                    this.empty = false;
                };
                this.clear = () => {
                    this.last = [
                        [null, null],
                        [null, null],
                    ];
                    this.past = [];
                    this.empty = true;
                };
                this.draw = (context, points) => {
                    context.drawWindow([points[0][0], points[0][1]], [points[1][0], points[1][1]]);
                };
                this.drawUser = (context) => {
                    const { drag, state } = this.handlers;
                    if (!this.empty && !state.inState("none")) {
                        context.drawClear();
                        context.drawDim();
                        this.past.forEach((points) => {
                            this.draw(context, points);
                        });
                        this.draw(context, this.last);
                    }
                    else if (!this.empty) {
                        context.drawClear();
                        context.drawDim();
                        this.draw(context, this.last);
                    }
                    else {
                        context.drawClear();
                    }
                };
                this.current = [
                    [null, null],
                    [null, null],
                ];
                this.last = [
                    [null, null],
                    [null, null],
                ];
                this.past = [];
                this.empty = true;
                this.handlers = handlers;
                this.bgDrawn = false;
            }
            get lastComplete() {
                return !this.last.flat().some((e) => e === null);
            }
        }
        exports.HighlightRects = HighlightRects;
    });
    define("auxiliaries/auxiliaries", ["require", "exports", "auxiliaries/Auxiliary", "auxiliaries/AxisBox", "auxiliaries/AxisText", "auxiliaries/AxisTitle", "auxiliaries/HighlightRects"], function (require, exports, Auxiliary_js_5, AxisBox_js_1, AxisText_js_1, AxisTitle_js_1, HighlightRects_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        __exportStar(Auxiliary_js_5, exports);
        __exportStar(AxisBox_js_1, exports);
        __exportStar(AxisText_js_1, exports);
        __exportStar(AxisTitle_js_1, exports);
        __exportStar(HighlightRects_js_1, exports);
    });
    define("plot/GraphicStack", ["require", "exports", "plot/GraphicLayer"], function (require, exports, GraphicLayer_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.GraphicStack = void 0;
        class GraphicStack {
            constructor(element, globals, dimensions) {
                this.initialize = () => {
                    const graphicLayers = ["graphicBase", "graphicUser", "graphicHighlight"];
                    this.graphicDiv.appendChild(this.graphicContainer);
                    this.graphicContainer.setAttribute("class", "graphicContainer");
                    graphicLayers.forEach((e) => {
                        this[e] = new GraphicLayer_js_1.GraphicLayer(this.globals, this.dimensions);
                        this.graphicContainer.appendChild(this[e].canvas);
                    });
                    this.graphicBase.drawBackground();
                };
                this.graphicDiv = element;
                this.graphicContainer = document.createElement("div");
                this.globals = globals;
                this.dimensions = dimensions;
                this.initialize();
            }
            get width() {
                if (this.dimensions)
                    return this.dimensions.width;
                return this.globals.plotWidth;
            }
            get height() {
                if (this.dimensions)
                    return this.dimensions.height;
                return this.globals.plotHeight;
            }
        }
        exports.GraphicStack = GraphicStack;
    });
    define("plot/Plot", ["require", "exports", "functions", "auxiliaries/auxiliaries", "handlers/handlers", "plot/GraphicStack"], function (require, exports, funs, auxs, hndl, GraphicStack_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Plot = void 0;
        class Plot extends GraphicStack_js_1.GraphicStack {
            constructor(id, element, mapping, globals, dimensions) {
                super(element, globals, dimensions);
                this.resize = () => {
                    const graphicLayers = ["graphicBase", "graphicUser", "graphicHighlight"];
                    this.scales.x.setLength(this.width);
                    this.scales.y.setLength(this.height);
                    this.graphicContainer.style.width = `${this.width}px`;
                    this.graphicContainer.style.height = `${this.height}px`;
                    graphicLayers.forEach((e) => this[e].resize());
                };
                this.activate = () => {
                    this.handlers.state.deactivateAll();
                    this.handlers.state.activate(this.id);
                };
                // Calls a method (string) on each child of a property (string)
                // e.g. call method "drawBase" on each child of "representations"
                this.callChildren = (object, fun, ...args) => {
                    const obj = this[object];
                    Object.keys(obj).forEach((child) => {
                        obj[child][fun] ? obj[child][fun](...args) : null;
                    });
                };
                // Returns a result of a function [string] from each child of a property [string]
                // e.g. return selected points from each representation
                this.mapChildren = (object, fun, ...args) => {
                    const obj = this[object];
                    return Object.keys(obj).map((child) => {
                        return obj[child][fun] ? obj[child][fun](...args) : null;
                    });
                };
                // Gets all unique values of a mapping [string], across all wranglers
                this.getUnique = (mapping) => {
                    const { wranglers } = this;
                    const arr = Object.keys(wranglers).flatMap((name) => { var _a; return (_a = wranglers[name][mapping].extract()) !== null && _a !== void 0 ? _a : []; });
                    return Array.from(new Set(arr));
                };
                // Given an array of selection points, checks each representation
                this.inSelection = (selPoints) => {
                    const { mapChildren } = this;
                    const allPoints = mapChildren("representations", "inSelection", selPoints);
                    return Array.from(new Set(allPoints.flat()));
                };
                this.inClickPosition = (clickPoint) => {
                    const { mapChildren } = this;
                    const allPoints = mapChildren("representations", "atClick", clickPoint);
                    return Array.from(new Set(allPoints.flat()));
                };
                this.startDrag = () => {
                    const { marker, state, drag } = this.handlers;
                    const { highlightrects } = this.auxiliaries;
                    if (!state.inState("none") && highlightrects.lastComplete) {
                        highlightrects.pushLastToPast();
                    }
                    highlightrects.updateCurrentOrigin(drag.start);
                };
                this.whileDrag = () => {
                    const { marker, drag, state } = this.handlers;
                    const { highlightrects } = this.auxiliaries;
                    highlightrects.updateCurrentEndpoint(drag.end);
                    highlightrects.updateLast();
                    this.drawUser();
                    marker.updateCurrent(this.inSelection([drag.start, drag.end]), state.membership);
                };
                this.endDrag = () => {
                    const { marker, state } = this.handlers;
                    const { highlightrects } = this.auxiliaries;
                    marker.mergeCurrent();
                    if (!state.inState("none") && highlightrects.lastComplete) {
                        highlightrects.pushLastToPast();
                    }
                };
                this.onKeypress = () => {
                    const { callChildren, drawHighlight } = this;
                    const { keypress } = this.handlers;
                    callChildren("handlers", "onKeypress", keypress.lastPressed);
                    if (this.active) {
                        callChildren("representations", "onKeypress", keypress.lastPressed);
                        drawHighlight();
                    }
                };
                this.onKeyRelease = () => {
                    const { handlers, callChildren } = this;
                    callChildren("handlers", "onKeyRelease", handlers.keypress.lastPressed);
                    if (this.active) {
                        callChildren("representations", "onKeyRelease", handlers.keypress.lastPressed);
                    }
                };
                this.onMouseDownAnywhere = () => {
                    const { marker, state } = this.handlers;
                    if (state.inState("none")) {
                        this.auxiliaries.highlightrects.clear();
                        this.drawUser();
                    }
                };
                this.onMouseDownHere = () => {
                    const { marker, click, drag, state } = this.handlers;
                    const { highlightrects } = this.auxiliaries;
                    if (state.inState("none")) {
                        marker.clearCurrent();
                        this.auxiliaries.highlightrects.clear();
                    }
                    state.deactivateAll();
                    this.activate();
                    marker.updateCurrent(this.inClickPosition(click.clickLast), state.membership);
                };
                this.onDoubleClick = () => {
                    const { marker, drag, state } = this.handlers;
                    state.activateAll();
                    marker.clearAll();
                    this.auxiliaries.highlightrects.clear();
                    this.drawHighlight();
                    this.drawUser();
                    state.deactivateAll();
                };
                this.draw = (context, ...args) => {
                    const { representations, auxiliaries, callChildren } = this;
                    const what = "draw" + funs.capitalize(context);
                    const where = "graphic" + funs.capitalize(context);
                    if (context !== "user")
                        this[where].drawClear();
                    if (context === "base")
                        this[where].drawBackground();
                    callChildren("representations", what, this[where], ...args);
                    callChildren("auxiliaries", what, this[where], ...args);
                };
                this.drawBase = () => this.draw("base");
                this.drawHighlight = () => this.draw("highlight");
                this.drawUser = () => {
                    if (this.active || this.handlers.state.inState("none"))
                        this.draw("user");
                };
                this.drawRedraw = () => {
                    this.drawBase();
                    this.drawHighlight();
                    this.drawUser();
                };
                this.initialize = () => {
                    const { handlers, scales, callChildren, onMouseDownHere, onMouseDownAnywhere, onDoubleClick, onKeypress, onKeyRelease, drawBase, drawHighlight, drawUser, startDrag, whileDrag, endDrag, graphicContainer, graphicDiv, } = this;
                    Object.keys(scales).forEach((mapping) => {
                        var _a;
                        (_a = scales[mapping]) === null || _a === void 0 ? void 0 : _a.registerData(this.getUnique(mapping));
                    });
                    callChildren("representations", "registerScales", scales);
                    callChildren("auxiliaries", "registerScales", scales);
                    this.handlers.drag.state = this.handlers.state;
                    graphicDiv.addEventListener("dblclick", onDoubleClick);
                    graphicDiv.addEventListener("mousedown", onMouseDownAnywhere);
                    graphicContainer.addEventListener("mousedown", onMouseDownHere);
                    handlers.marker.registerCallbacks([drawHighlight, drawHighlight], ["updateCurrent", "clearAll"]);
                    handlers.state.registerCallbacks([drawUser], ["deactivateAll"]);
                    handlers.drag.registerCallbacks([startDrag, whileDrag, endDrag], ["startDrag", "whileDrag", "endDrag"]);
                    handlers.keypress.registerCallbacks([onKeypress, onKeyRelease, drawBase], ["keyPressed", "keyReleased", "keyPressed"]);
                    drawBase();
                };
                this.id = id;
                this.representations = {};
                this.wranglers = {};
                this.scales = {};
                this.handlers = {
                    marker: globals.handlers.marker,
                    keypress: globals.handlers.keypress,
                    state: globals.handlers.state,
                    drag: new hndl.DragHandler(this.graphicContainer),
                    click: new hndl.ClickHandler(this.graphicContainer),
                };
                this.auxiliaries = {
                    axisbox: new auxs.AxisBox(),
                    axistextx: new auxs.AxisText("x"),
                    axistexy: new auxs.AxisText("y"),
                    axistitlex: new auxs.AxisTitle("x", mapping.get("x")),
                    axistitley: new auxs.AxisTitle("y", mapping.get("y")),
                    highlightrects: new auxs.HighlightRects(this.handlers),
                };
            }
            get active() {
                return this.handlers.state.isActive(this.id);
            }
        }
        exports.Plot = Plot;
    });
    define("handlers/ClickHandler", ["require", "exports", "handlers/Handler"], function (require, exports, Handler_js_5) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.ClickHandler = void 0;
        class ClickHandler extends Handler_js_5.Handler {
            //clickArray: [number, number][];
            constructor(container) {
                super();
                this.mouseDown = (event) => {
                    this.holding = true;
                    this.clickCurrent = [event.offsetX, event.offsetY];
                    this.clickLast = [event.offsetX, event.offsetY];
                    this.notifyAll("mouseDown");
                };
                this.mouseUp = (event) => {
                    this.holding = false;
                    this.clickCurrent = [null, null];
                    this.notifyAll("mouseUp");
                };
                this.container = container;
                this.holding = false;
                this.clickCurrent = [null, null];
                this.clickLast = [null, null];
                this.actions = ["mousedown", "mouseup"];
                this.consequences = ["mouseDown", "mouseUp"];
                // Register key press/release behavior on the document body
                this.actions.forEach((action, i) => {
                    this.container.addEventListener(action, (event) => this[this.consequences[i]](event));
                });
            }
        }
        exports.ClickHandler = ClickHandler;
    });
    define("handlers/handlers", ["require", "exports", "handlers/MarkerHandler", "handlers/KeypressHandler", "handlers/DragHandler", "handlers/StateHandler", "handlers/ClickHandler"], function (require, exports, MarkerHandler_js_1, KeypressHandler_js_1, DragHandler_js_1, StateHandler_js_1, ClickHandler_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        __exportStar(MarkerHandler_js_1, exports);
        __exportStar(KeypressHandler_js_1, exports);
        __exportStar(DragHandler_js_1, exports);
        __exportStar(StateHandler_js_1, exports);
        __exportStar(ClickHandler_js_1, exports);
    });
    define("datastructures", ["require", "exports"], function (require, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.plotTypeArray = exports.highlightMembershipArray = exports.validMembershipArray = exports.baseMembershipArray = void 0;
        const baseMembershipArray = [1, 2, 3, 4];
        exports.baseMembershipArray = baseMembershipArray;
        const validMembershipArray = [
            ...baseMembershipArray,
            ...baseMembershipArray.map((e) => e + 128),
            128,
        ];
        exports.validMembershipArray = validMembershipArray;
        const highlightMembershipArray = validMembershipArray.filter((e) => e !== 1);
        exports.highlightMembershipArray = highlightMembershipArray;
        const plotTypeArray = ["scatter", "bubble", "bar", "histo", "square"];
        exports.plotTypeArray = plotTypeArray;
    });
    define("plot/ScatterPlot", ["require", "exports", "scales/scales", "representations/representations", "wrangler/Wrangler", "plot/Plot"], function (require, exports, scls, reps, Wrangler_js_1, Plot_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.ScatterPlot = void 0;
        class ScatterPlot extends Plot_js_1.Plot {
            constructor(id, element, mapping, globals, dimensions) {
                super(id, element, mapping, globals, dimensions);
                this.mapping = mapping;
                this.wranglers = {
                    wrangler1: new Wrangler_js_1.Wrangler(globals.data, mapping, globals.handlers.marker).extractAsIs(...mapping.keys()),
                };
                this.scales = Object.assign({ x: new scls.XYScaleContinuous(this.width), y: new scls.XYScaleContinuous(this.height, -1) }, (mapping.get("size") && { size: new scls.AreaScaleContinuous(10) }));
                this.representations = {
                    points: new reps.Points(this.wranglers.wrangler1),
                };
                this.initialize();
            }
        }
        exports.ScatterPlot = ScatterPlot;
    });
    define("plot/BubblePlot", ["require", "exports", "scales/scales", "representations/representations", "functions", "wrangler/Wrangler", "plot/Plot"], function (require, exports, scls, reps, funs, Wrangler_js_2, Plot_js_2) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.BubblePlot = void 0;
        class BubblePlot extends Plot_js_2.Plot {
            constructor(id, element, mapping, globals, dimensions) {
                if (!mapping.has("size"))
                    mapping.set("size", "_indicator");
                super(id, element, mapping, globals, dimensions);
                this.wranglers = {
                    wrangler1: new Wrangler_js_2.Wrangler(globals.data, mapping, globals.handlers.marker)
                        .splitBy("x", "y")
                        .splitWhat("size")
                        .doWithin("by", funs.unique)
                        .doWithin("what", funs.length)
                        .assignIndices(),
                };
                this.scales = {
                    x: new scls.XYScaleDiscrete(this.width),
                    y: new scls.XYScaleDiscrete(this.height, -1),
                    size: new scls.AreaScaleContinuous(this.width),
                };
                this.representations = {
                    points: new reps.Points(this.wranglers.wrangler1),
                };
                this.initialize();
            }
        }
        exports.BubblePlot = BubblePlot;
    });
    define("plot/BarPlot", ["require", "exports", "scales/scales", "representations/representations", "functions", "wrangler/Wrangler", "plot/Plot"], function (require, exports, scls, reps, funs, Wrangler_js_3, Plot_js_3) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.BarPlot = void 0;
        class BarPlot extends Plot_js_3.Plot {
            constructor(id, element, mapping, globals, dimensions) {
                super(id, element, mapping, globals, dimensions);
                this.mapping = mapping;
                this.wranglers = {
                    wrangler1: new Wrangler_js_3.Wrangler(globals.data, mapping, globals.handlers.marker)
                        .splitBy("x")
                        .splitWhat("y")
                        .doWithin("by", funs.unique)
                        .doWithin("what", funs.sum)
                        .assignIndices(),
                };
                this.scales = {
                    x: new scls.XYScaleDiscrete(this.width),
                    y: new scls.XYScaleContinuous(this.height, -1, true),
                };
                this.representations = {
                    bars: new reps.Bars(this.wranglers.wrangler1, 0.8),
                };
                this.initialize();
            }
        }
        exports.BarPlot = BarPlot;
    });
    define("plot/HistoPlot", ["require", "exports", "scales/scales", "representations/representations", "functions", "wrangler/Wrangler", "plot/Plot"], function (require, exports, scls, reps, funs, Wrangler_js_4, Plot_js_4) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.HistoPlot = void 0;
        class HistoPlot extends Plot_js_4.Plot {
            constructor(id, element, mapping, globals, dimensions) {
                super(id, element, mapping, globals, dimensions);
                this.wranglers = {
                    wrangler1: new Wrangler_js_4.Wrangler(globals.data, mapping, globals.handlers.marker)
                        .splitBy("x")
                        .splitWhat("y")
                        .doAcross("by", funs.bin, 10)
                        .doWithin("by", funs.unique)
                        .doWithin("what", funs.length)
                        .assignIndices(),
                };
                this.scales = {
                    x: new scls.XYScaleContinuous(this.width),
                    y: new scls.XYScaleContinuous(this.height, -1, true),
                };
                this.representations = {
                    bars: new reps.Bars(this.wranglers.wrangler1, 1),
                };
                this.initialize();
            }
        }
        exports.HistoPlot = HistoPlot;
    });
    define("plot/SquarePlot", ["require", "exports", "scales/scales", "representations/representations", "functions", "wrangler/Wrangler", "plot/Plot"], function (require, exports, scls, reps, funs, Wrangler_js_5, Plot_js_5) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.SquarePlot = void 0;
        class SquarePlot extends Plot_js_5.Plot {
            constructor(id, element, mapping, globals, dimensions) {
                if (!mapping.has("size"))
                    mapping.set("size", "_indicator");
                super(id, element, mapping, globals, dimensions);
                this.wranglers = {
                    wrangler1: new Wrangler_js_5.Wrangler(globals.data, mapping, globals.handlers.marker)
                        .splitBy("x", "y")
                        .splitWhat("size")
                        .doWithin("by", funs.unique)
                        .doWithin("what", funs.length)
                        .assignIndices(),
                };
                this.scales = {
                    x: new scls.XYScaleDiscrete(this.width),
                    y: new scls.XYScaleDiscrete(this.height, -1),
                    size: new scls.AreaScaleContinuous(this.width),
                };
                this.representations = {
                    points: new reps.Squares(this.wranglers.wrangler1),
                };
                this.initialize();
            }
        }
        exports.SquarePlot = SquarePlot;
    });
    define("plot/plots", ["require", "exports", "plot/ScatterPlot", "plot/BubblePlot", "plot/BarPlot", "plot/HistoPlot", "plot/SquarePlot"], function (require, exports, ScatterPlot_js_1, BubblePlot_js_1, BarPlot_js_1, HistoPlot_js_1, SquarePlot_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        __exportStar(ScatterPlot_js_1, exports);
        __exportStar(BubblePlot_js_1, exports);
        __exportStar(BarPlot_js_1, exports);
        __exportStar(HistoPlot_js_1, exports);
        __exportStar(SquarePlot_js_1, exports);
    });
    define("Mapping", ["require", "exports"], function (require, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Mapping = void 0;
        class Mapping extends Map {
            constructor(...mappings) {
                super([...mappings]);
                if (!this.has("y"))
                    this.set("y", "_indicator");
            }
        }
        exports.Mapping = Mapping;
    });
    define("helppaneltext", ["require", "exports"], function (require, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.helpPanelText = void 0;
        exports.helpPanelText = `
        Welcome to Plotscape! <br>
        Try interacting with the plots in the following ways: <br> <br>
        <kbd>Click</kbd> a plot to make it active <br>
        <kbd>+</kbd>/<kbd>-</kbd> to increase/decrease size of objects <br>
        <kbd>[</kbd>/<kbd>]</kbd> to decrease/increase opacity (alpha) of objects <br>
        <kbd>R</kbd> to reset graphical settings of the active plot <br>
        <kbd>Click-and-drag</kbd>/<kbd>click</kbd> to transiently select objects<br>
        <kbd>1</kbd>,<kbd>2</kbd>,<kbd>...</kbd> + <kbd>click-and-drag</kbd> to make a permanent (group) selection <br>
        <kbd>Double-click</kbd> to reset selection
    
        <br>
    `;
    });
    define("Scene", ["require", "exports", "datastructures", "handlers/handlers", "plot/plots", "helppaneltext"], function (require, exports, dtstr, hndl, plts, helppaneltext_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.Scene = void 0;
        class Scene {
            constructor(element, data) {
                this.addPlotWrapper = (plotType, mapping, dimensions) => {
                    const { element, plotIds, plots, globals } = this;
                    this.globals.nPlots++;
                    const plotTypeIndex = dtstr.plotTypeArray.findIndex((e) => e === plotType);
                    this.nPlotsOfType[plotTypeIndex]++;
                    const plotId = `${plotType}${this.nPlotsOfType[plotTypeIndex]}`;
                    this.plots[plotId] = new PlotProxy(plotType, plotId, element, mapping, globals, dimensions);
                    plotIds.push(plotId);
                    globals.handlers.state.plotIds.push(plotId);
                    globals.handlers.state.plotsActive.push(false);
                    globals.handlers.state.plotContainers.push(this.plots[plotId].graphicContainer);
                    plotIds.forEach((e) => {
                        plots[e].resize();
                        plots[e].drawRedraw();
                    });
                    return this;
                };
                this.element = element;
                this.nObs = data[Object.keys(data)[0]].length;
                this.nPlotsOfType = Array(dtstr.plotTypeArray.length).fill(0);
                this.plots = {};
                this.plotIds = [];
                this.globals = {
                    nPlots: 0,
                    scaleFactor: 3,
                    data: data,
                    sceneWidth: parseInt(getComputedStyle(element).width, 10),
                    sceneHeight: parseInt(getComputedStyle(element).height, 10),
                    get plotWidth() {
                        return ((0.85 * this.sceneWidth) /
                            Math.ceil(this.nPlots / Math.floor(Math.sqrt(this.nPlots))));
                    },
                    get plotHeight() {
                        return (0.85 * this.sceneHeight) / Math.floor(Math.sqrt(this.nPlots));
                    },
                    handlers: {
                        marker: new hndl.MarkerHandler(this.nObs),
                        keypress: new hndl.KeypressHandler(),
                        state: new hndl.StateHandler(),
                    },
                };
                element.classList.add("graphicDiv");
                this.globals.handlers.state.keypressHandler =
                    this.globals.handlers.keypress;
                // Inject css
                const head = document.head;
                const link = document.createElement("link");
                link.type = "text/css";
                link.rel = "stylesheet";
                link.href = "./styles.css";
                head.appendChild(link);
                // Add help button and panel
                const helpButton = document.createElement("button");
                const helpPanel = document.createElement("div");
                helpButton.innerText = `?`;
                helpButton.classList.add("buttonHelp");
                helpPanel.innerHTML = helppaneltext_js_1.helpPanelText;
                helpPanel.classList.add("helpPanel");
                const helpButtonDim = Math.min(this.globals.sceneWidth, this.globals.sceneHeight) * 0.05;
                helpButton.style.width = `${helpButtonDim}px`;
                helpButton.style.height = `${helpButtonDim}px`;
                helpButton.style.fontSize = `${0.5 * helpButtonDim}px`;
                element.appendChild(helpPanel);
                element.appendChild(helpButton);
                helpButton.addEventListener("click", (event) => {
                    helpPanel.classList.toggle("activePanel");
                });
            }
        }
        exports.Scene = Scene;
        // A class that dynamically constructs a wrapper plot given
        // a plot type (string), data, mapping, and global handlers
        class PlotProxy {
            constructor(plotType, ...args) {
                const plotClasses = {
                    scatter: plts.ScatterPlot,
                    bubble: plts.BubblePlot,
                    bar: plts.BarPlot,
                    histo: plts.HistoPlot,
                    square: plts.SquarePlot,
                };
                return new plotClasses[plotType](...args);
            }
        }
    });
    define("main", ["require", "exports", "Scene", "plot/Plot", "DataFrame", "Mapping", "functions"], function (require, exports, Scene_js_1, Plot_js_6, DataFrame_js_1, Mapping_js_1, functions_js_1) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        __exportStar(Scene_js_1, exports);
        __exportStar(Plot_js_6, exports);
        __exportStar(DataFrame_js_1, exports);
        __exportStar(Mapping_js_1, exports);
        __exportStar(functions_js_1, exports);
    });
    
    'marker:resolver';

    function get_define(name) {
        if (defines[name]) {
            return defines[name];
        }
        else if (defines[name + '/index']) {
            return defines[name + '/index'];
        }
        else {
            const dependencies = ['exports'];
            const factory = (exports) => {
                try {
                    Object.defineProperty(exports, "__cjsModule", { value: true });
                    Object.defineProperty(exports, "default", { value: require(name) });
                }
                catch (_a) {
                    throw Error(['module "', name, '" not found.'].join(''));
                }
            };
            return { dependencies, factory };
        }
    }
    const instances = {};
    function resolve(name) {
        if (instances[name]) {
            return instances[name];
        }
        if (name === 'exports') {
            return {};
        }
        const define = get_define(name);
        if (typeof define.factory !== 'function') {
            return define.factory;
        }
        instances[name] = {};
        const dependencies = define.dependencies.map(name => resolve(name));
        define.factory(...dependencies);
        const exports = dependencies[define.dependencies.indexOf('exports')];
        instances[name] = (exports['__cjsModule']) ? exports.default : exports;
        return instances[name];
    }
    if (entry[0] !== null) {
        return resolve(entry[0]);
    }
})();
/**
 * Created by pappg on 20/12/2016.
 */

var valueChangedDartCallback;
var selectionChangedDartCallback;

var DataTable = function () {
    this.matrixData = [
        ["", "A", "B", "C"],
        ["D", 1, 1, 1],
        ["E", 1, 1, 1],
        ["F", 1, 1, 1]
    ];

    this.handsonTable = null;
    this.selection = {
        rowBegin: 1,
        colBegin: 1,
        rowEnd: 1,
        colEnd: 1,

        minRow: function(){
            return Math.min(this.rowBegin, this.rowEnd);
        },

        minCol: function(){
            return Math.min(this.colBegin, this.colEnd);
        },

        maxRow: function(){
            return Math.max(this.rowBegin, this.rowEnd);
        },

        maxCol: function(){
            return Math.max(this.colBegin, this.colEnd);
        }
    };
};

DataTable.prototype.createTable = function(containerElementID, valueChanged, selectionChanged) {
    var container = document.querySelector(containerElementID);

    valueChangedDartCallback = valueChanged;
    selectionChangedDartCallback = selectionChanged;

    var afterChange = this._valueChange;
    var afterSelection = this._selectionChanged;

    var matrixSettings = {
        data: this.matrixData,
        minSpareRows: 0,
        afterChange: afterChange,
        afterSelection: afterSelection,
        beforeChange: afterChange
    };
    this.handsonTable = new Handsontable(container, matrixSettings);
};

DataTable.prototype._selectionChanged = function(rowBegin, colBegin, rowEnd, colEnd){
    selection = {
        rowBegin: rowBegin,
        colBegin: colBegin,
        rowEnd: rowEnd,
        colEnd: colEnd,

        minRow: function(){
            return Math.min(this.rowBegin, this.rowEnd);
        },

        minCol: function(){
            return Math.min(this.colBegin, this.colEnd);
        },

        maxRow: function(){
            return Math.max(this.rowBegin, this.rowEnd);
        },

        maxCol: function(){
            return Math.max(this.colBegin, this.colEnd);
        }
    };

    selectionChangedDartCallback([rowBegin, rowEnd, colBegin, colEnd], "editor");
};

DataTable.prototype.refreshTable = function () {
    this.handsonTable.loadData(this.matrixData);
};

DataTable.prototype._valueChange = function(changes, source){
    if (source !== 'loadData') {
        valueChangedDartCallback(changes, source);
    }
};

DataTable.prototype.changeMatrixData = function(source, row, col){
    this.matrixData = this._initMatrix(row, col);
    for(var i = 0; i < row; i++){
        for(var j = 0; j < col; j++){
            this.matrixData[i][j] = source[i][j][0];
        }
    }
};

DataTable.prototype._initMatrix = function (row, col) {
    var matrix = [];
    for(var i = 0; i < row; i++){
        var array = [];
        for(var j = 0; j < col; j++){
            array.push(0);
        }
        matrix.push(array);
    }
    return matrix;
};


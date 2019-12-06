function showGraph(data){
    /*var nodes = new vis.DataSet([
        {id: 1, label: 'PTEN', color:"#00ff00", shape:"triangle"},
        {id: 2, label: 'MTOR', color:"#ff0000"},
        {id: 3, label: 'TP53', color:"#ff0000"},
        {id: 4, label: 'USP7', color:"#ff0000"},
        {id: 5, label: 'AKT1', color:"#ff0000"}
    ]);

    // create an array with edges
    var edges = new vis.DataSet([
        {from: 1, to: 2},
        {from: 1, to: 3},
        {from: 1, to: 4},
        {from: 1, to: 4},
        {from: 1, to: 5}
    ]);*/

    // create a network
    var container = document.getElementById('network');

    // provide the data in the vis format
    /*var data = {
        nodes: nodes,
        edges: edges
    };*/
    var options = {};

    // initialize your network!
    var network = new vis.Network(container, data, options);

}
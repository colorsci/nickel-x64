var SystemPerformanceConnection,GPUPerformanceCharts,NetworkPerfChart,MemoryChart,IOChart,CPUChart;$(function(){var n=new NetworkPerfChart("Network");new SystemPerformanceConnection("networkPerfConnectionStatus",{networkCallback:n.onMessageCallback})});
/*!
//@ sourceURL=tools/NetworkPerformance/NetworkPerformance.js
*/

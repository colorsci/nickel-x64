var SystemPerformanceConnection,GPUPerformanceCharts;$(function(){var n=new GPUPerformanceCharts("GPU",{showAveragePlot:!1,showMemoryPlots:!1,engineBitmap:255});new SystemPerformanceConnection("gpuPerfConnectionStatus",{gpuCallback:n.onMessageCallback})});
/*!
//@ sourceURL=tools/GpuPerformance/GpuPerformance.js
*/

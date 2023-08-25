/* global config: true, QRCode: true */
const data = JSON.parse(window.appBridge.datasource),
	devInfo = data.deviceInformation, skuInfo = devInfo.skuInformation,
	sku = devInfo.RetailInfo.SKU || devInfo.RetailInfo.sku || skuInfo.sku,
	rac = devInfo.RetailInfo.RetailAccessCode || devInfo.RetailInfo.rac || devInfo.RetailInfo.RAC,
	store = devInfo.RetailInfo.StoreID;
function el(s) { return document.querySelector(s); }
el('main').style.setProperty('--theme', config.oemColor[(skuInfo.oem || '').toLowerCase()] || config.oemColor.windows);
function setLogo(file) { el('#Logo').src = `./logos/${(file || '').toLowerCase()}.png`; }
setLogo(skuInfo.oem);
el('#Logo').addEventListener('error', _ => setLogo('Windows'));
// el('#ProductName').innerText = 'A great Windows experience';
/* el('#ProductCPU').innerText = skuInfo.spec_items.processor || devInfo.RetailInfo['Detected\\Processor'] || '[CPU]';
el('#ProductRAM').innerText = skuInfo.spec_items.memory || devInfo.RetailInfo['Detected\\Memory'] || '[Memory]';
el('#ProductHD').innerText = skuInfo.spec_items.storage || devInfo.RetailInfo['Detected\\Storage'] || '[Storage]';
*/
if (config.image) { el('#ProductImg').src = skuInfo.images.compare; }
else { el('pic-area').remove(); }
new QRCode(el('qr-code'), { // eslint-disable-line no-new
	text: 'https://aka.ms/rdxoct21',
	correctLevel: QRCode.CorrectLevel.Q, width: 512, height: 512, colorDark: '#000000', colorLight: '#EFEFEF'
});
if (config.vertical) { el('main').setAttribute('vertical', true); }
el('main').classList.add('position' + Math.floor((Math.random() * 4) + 1));
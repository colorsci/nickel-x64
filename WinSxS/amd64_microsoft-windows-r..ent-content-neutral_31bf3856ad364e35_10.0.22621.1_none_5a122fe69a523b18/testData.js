/* eslint-disable camelcase */
if (!window.appBridge) { document.documentElement.style.backgroundColor = 'gray'; }
window.appBridge = { datasource: JSON.stringify({
	deviceInformation: {
		RetailInfo: {
			Platform: 'Desktop',
			OSVersion: '21H2',
			Region: 'United States (US)',
			ManufacturerName: 'Microsoft Corporation',
			ModelName: 'Fabrikam PC',
			Retailer: 'Contoso',
			RetailAccessCode: 'ContosoDemo',
			SKU: '000000',
			Language: 'English (en)',
			SignatureDevice: 'False',
			HasWinBioUnits: 'True',
			PenEnabled: 'False',
			EditionID: 'Professional',
			staging: 'True',
			CampaignName: '',
			screenCaptureMode: 'True',

			'Detected\\WindowsEdition': 'Windows 10 Professional'
		},
		skuInformation: {
			sku: '000000',
			description: '512GB / Intel® Core™ i7 / dGPU',
			product_name: 'Fabrikam Laptop 5000',
			oem_name: 'Microsoft',
			oem: 'Microsoft',
			model: 'Surface Book 2',
			link: 'https://www.microsoft.com/en-us/store/d/surface-book-2/8MCPZJJCC98C/VKHH',
			images: {
				hero: 'Cache\\1vmy2lDll8FPRX7D1Ux6wSS7Xbw=',
				compare: 'surface3.jpg'
			},
			spec_items: {
				screen: '13.5" PixelSence™ Display with 3000 x 2000 resolution',
				processor: 'Intel Core i5',
				memory: '8GB RAM',
				storage: '512GB SSD',
				battery: 'Up to 17 hours battery life',
				graphics: 'Blazing NVIDIA graphics performance',
				weight: 'Starting at 3.38lbs (1,534g)',
				hello: 'Included',
				pen: 'Compatible',
				touch: 'Included',
				cortana: 'Included',
				mixed_reality: 'Ultra',
				ports: 'New USB-C port'
			},
		}
	},
	branding: {
		color: { oem: '#0085C3' },
		oem_logo: 'msLogo.png',
		oem_logoTab: 'oem_assets/Dell_Logo_2_220.png'
	}
}) };
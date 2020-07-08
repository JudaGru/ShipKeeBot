module.exports = {
  getLabel: async function getLabel(
    orderNumber,
    weight,
    value,
    width,
    height,
    length
  ) {
    const puppeteer = require("puppeteer");
    // getQuotes();
    // async function getQuotes(){
    const browser = await puppeteer.launch({
      headless: false,
      timeout: 90000,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    });

    const page = await browser.newPage();

    await page.goto("https://shipkee.com/");
    await page.waitFor("body");
    await page.click("a#btnLoginDropdown");

    await page.waitFor(1000);

    await page.waitForSelector("input#input_0");
    await page.waitForSelector("input#input_1");

    await page.type("input#input_0", "wayne@namebrandoverstock.com");
    await page.type("input#input_1", "wayne123me");

    await page.click("#loginForm > div.form-group.text-right > button");

    await page.waitForNavigation();

    await page.goto("https://shipkee.com/Customer/CreateShipment");
    await page.waitFor(2000);
    await page.click("#selectToAddress");
    await page.waitFor(2000);
    await page.click("#abctest > div.single-address-row > div:nth-child(1) > div");

    await page.type("#NickName1",'yehudag');
    await page.type("#Company1",'yehudag');
    await page.type("#Name1",'yehudag');
    await page.type("#AddressLine11",'55 Schilling Rd');
    await page.type("#AddressLine21",'');
    // await page.click("#State1");
    await page.select("#State1",'object:767');
    await page.type("#City1","Hunt Valley");
    await page.type("#Zip1","21031");
    await page.type("#Telephone1","17181234567");
    // object:767
    // #State1 > option:nth-child(3)
    console.log('5');

    if(true){
        await page.click("#AddAddressHome1");

    }
    else{
        await page.click("#AddAddressOffice1");

    }

    console.log('6');
    
    
    await page.click("#formAddAddress > div.modal-footer > button.btn.btn-green.btn-md.save-address-loader-position.width-100");
    console.log('7');
    await page.waitFor(2000);
    await page.click("#abctest > div.single-address-row > div:nth-child(2) > div");
    await page.waitFor(2000);
    await page.click("#shipmentContainer");
    await page.waitFor(2000);

    await page.click("#mCSB_4_container > div.address-book-list.package > div > div:nth-child(2) > div > div.add-footer > a");
    await page.waitFor(2000);
    // weight
    await page.type("#formEditPackage > div.ng-scope > div:nth-child(1) > div.package-dimensions-group.ng-scope > div:nth-child(2) > input","1");
    // value
    await page.type("#formEditPackage > div.ng-scope > div:nth-child(1) > div.package-dimensions-group.ng-scope > div:nth-child(3) > input","1");
    //width
    await page.type("#formEditPackage > div.ng-scope > div:nth-child(1) > div.package-dimensions-group.ng-scope > div.ng-scope > div:nth-child(1) > input","1");
   // height
    await page.type("#formEditPackage > div.ng-scope > div:nth-child(1) > div.package-dimensions-group.ng-scope > div.ng-scope > div:nth-child(2) > input","1");
    // length
    await page.type("#formEditPackage > div.ng-scope > div:nth-child(1) > div.package-dimensions-group.ng-scope > div.ng-scope > div:nth-child(3) > input","1");
    
    // click update
    await page.click("#formEditPackage > div.modal-footer > button.btn.btn-green.btn-md.update-address-loader-position.width-100");
    await page.waitFor(2000);




    await browser.close();
  },
};

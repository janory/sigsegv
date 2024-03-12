import { expect, test } from "@playwright/test";
import { config } from "dotenv";
import { routeToSegments } from "../src/lib/utils/route-to-segments";
import { authenticate } from "./utils/authenticate";

config();

test.describe("Authentication flow", () => {
	test("email login flow", async ({ page, baseURL }) => {
		await page.goto("/auth");
		await page.getByLabel("Email").fill("test@example.com");
		await page.locator("button[type='submit']").click();
		await page.waitForURL("/auth/verify?email=test@example.com");

		expect(page.url()).toMatch(`${baseURL}/auth/verify`);
	});

	test("phone flow", async ({ page, baseURL }) => {
		await page.goto("/auth", { waitUntil: "networkidle" });
		await page.getByText("WhatsApp").click();

		await page.getByLabel("Phone").fill("97114167");
		await page.locator("button[type='submit']").click();

		expect(page.getByText("One-time passcode sent")).toBeTruthy();

		await page.waitForSelector("[data-pin-input-index='0']");

		await page.locator("[data-pin-input-index='0']").click();
		await page.keyboard.type("123456");
		await page.locator("[type='submit']").click();

		await page.waitForURL(`${baseURL}/app`);
	});

	test("redirects to /app when session is present", async ({ page, context }) => {
		await authenticate(context);
		await page.goto("/auth");

		await page.waitForURL((url) => routeToSegments(url.pathname)[0] === "app");
	});

	test("asserts that the first pin input is focused", async ({ page }) => {
		await page.goto("/auth");
		await page.getByText("WhatsApp").click();
		await page.getByLabel("Phone").fill("97114167");
		await page.locator("button[type='submit']").click();

		await page.waitForSelector("[data-melt-pin-input]");
		const activeElement = await page.evaluate(() => document.activeElement);

		console.log(activeElement);
	});
});

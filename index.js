import express from "express"
import cors from "cors"
import { env } from "node:process"
import { ProfileInfo } from "@zowe/imperative"
import { SubmitJobs, MonitorJobs, GetJobs } from "@zowe/zos-jobs-for-zowe-sdk"
import { readFileSync } from "node:fs"

const PORT = 3000
const app = express()
app.use(cors(), express.json())

const datasetName = "RESULT"
const jclString = readFileSync("mainframe/GETHN.jcl").toString()

const session = await (async () => {
	const profInfo = new ProfileInfo("zowe")
	await profInfo.readProfilesFromDisk()
	const zosmfMergedArgs = profInfo.mergeArgsForProfile(profInfo.getDefaultProfile("zosmf"), {getSecureVals: true})
	const session = ProfileInfo.createSession(zosmfMergedArgs.knownArgs, {type: "basic"})
	return session
	})()

const getResult = async (value) => {
	const job = await SubmitJobs.submitJclCommon(session, {
		jcl: jclString.replace('&PARAMS', value),
	})

	const jobResult = await MonitorJobs.waitForStatusCommon(session, {
		jobname: job.jobname,
		jobid: job.jobid,
		status: "OUTPUT",
		attempts: 20
	})
	const spoolFiles = await GetJobs.getSpoolFiles(session, jobResult.jobname, jobResult.jobid)

	for (const spool of spoolFiles) {
		if (spool.ddname === datasetName) {
			const val = await GetJobs.getSpoolContentById(
				session, jobResult.jobname, 
				jobResult.jobid, spool.id, "UTF-8"
			)
			const trimmed = val.trimEnd();
			const regMatch = trimmed.match(/\{.*\}/s);
			if (regMatch) {
				const json = JSON.parse(regMatch[0]);
				return json
			}
		}
	}

	return {
		"TYPE-INFO": "ERROR",
		"REASON": `DATASET ${datasetName} NOT FOUND.`,
		"ERR-CODE": 500
	}
}

app.get("/", (req, res) => {
	res.send({
		routes: ["/api/hn/year/:year", "/api/hn/month/:month", "/api/hn/year/:year/:month"],
		allowedMethods: ["GET"]
	})
})

const handleRes = (res, jclResult) => {
	if (jclResult["TYPE-INFO"] === "ERROR") {
		res.status(jclResult["ERR-CODE"])
		delete jclResult["ERR-CODE"]
		res.send(jclResult)		
		return
	}
	res.status(200)
	res.send(jclResult)
}

app.get("/api/hn/year/:year", async (req, res) => {
	const year = req.params.year
	const jclResult = await getResult(`'YEAR=${year}'`)
	handleRes(res, jclResult)
})

app.get("/api/hn/month/:month", async (req, res) => {
	const month = req.params.month
	const jclResult = await getResult(`'MONTH=${month}'`)
	handleRes(res, jclResult)
})

app.get("/api/hn/year/:year/:month", async (req, res) => {
	const year = req.params.year
	const month = req.params.month
	const jclResult = await getResult(`'YEARMONTH=${year}${month}'`)
	handleRes(res, jclResult)
})

app.listen(PORT, (err) => {
	if (err) console.log(err)
	console.log("Server listening on PORT", PORT)
})

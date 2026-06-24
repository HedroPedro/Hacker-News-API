import express from "express"
import cors from "cors"
import { env } from 'node:process'
import { ProfileInfo } from "@zowe/imperative"
import { SubmitJobs, MonitorJobs, GetJobs } from "@zowe/zos-jobs-for-zowe-sdk"
import { readFileSync } from "node:fs"

const PORT = 3000
const app = express()
app.use(express.json(), cors())

const ZID = env.ZID
const datasetName = "RESULT"
const jclString = readFileSync("mainframe/GETHN.jcl")

if (ZID === undefined)
	throw new Error("ZID must be defined")

const getResult = async (value) => {
	const profInfo = new ProfileInfo("zowe")
	await profInfo.readProfilesFromDisk()
	const zosmfMergedArgs = profInfo.mergeArgsForProfile(profInfo.getDefaultProfile("zosmf"), {getValuesBack: true})
	const session = ProfileInfo.createSession(zosmfMergedArgs.knownArgs)
	const job = await SubmitJobs.submitJclCommon(session, {
		jcl: null,
		jclSymbols: {
			"PARAMS": value
		}
	})
	const jobResult = await MonitorJobs.waitForStatusCommon(session, {
		jobname: job.jobname,
		jobid: job.jobid,
		status: "OUTPUT",
		attempts: 20
	})
	const spoolFiles = await GetJobs.getSpoolFiles(session, jobResult.jobname, jobResult.jobid)

	for (const spool of spoolFiles) {
		console.log(spool.ddname)
	}
}

app.get("/", (req, res) => {
	res.send({
		routes: ["/api/hn/year/:year", "/api/hn/month/:month", "/api/hn/year/:year/:month"],
		allowedMethods: ["GET"]
	})
})

app.listen(PORT, (err) => {
	if (err) console.log(err)
	console.log("Server listening on PORT ", PORT)
})

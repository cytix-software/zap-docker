import express from 'express'
import dotenv from 'dotenv'
import { writeFile } from 'fs/promises'
import generateYaml from './generateYaml'
dotenv.config()
if (!process.env.ZAP_API_KEY) throw new Error('\x1b[31mEnvironment variable "ZAP_API_KEY" not set. This is required for authorising incoming requests.\x1b[0m')
if (!process.env.FILE_PATH) throw new Error('\x1b[31mEnvironment variable "FILE_PATH" not set. This is required for saving the YML file to a custom path.\x1b[0m')

const app = express()
app.use(express.json())

app.get('/', (req, res) => {
  return res.send('Healthy')
})

app.post('/yaml', async (req, res, next) => {
  // Check Authorization 
  if (req.headers.authorization !== process.env.ZAP_API_KEY) {
    return res.sendStatus(401)
  }

  // Validate body
  const body = <YamlRequest>req.body
  if (!body.username || !body.password) {
    res.statusCode = 400
    return res.json({ message: 'Username or password fields are undefined. Username and password are required in the request at a minimum.' })
  }
  if (!body.url) {
    res.statusCode = 400
    return res.json({ message: `"url" paramter wasn't supplied.` })
  }

  const yml = await generateYaml(body).catch((e) => next(e))
  if (!yml) return

  // Save to path set in environment variables
  await writeFile(process.env.FILE_PATH || './output.yml', yml)
  return res.send(yml)
})

app.listen(80, () => {
  console.log(`\n\x1b[33mServer running at \x1b[36mhttp://localhost:80\x1b[0m`)
})

export interface YamlRequest {
  username: string
  password: string
  url: string
  loginUrl?: string
  pollUrl?: string
  loggedInRegex?: string
  loggedOutRegex?: string
}
const inquirer = require('inquirer')

const rand = () => Math.floor(Math.random() * 1000000)

module.exports = () => {
  async function run() {

    const value = rand()

    const prompt = await inquirer.prompt([
      {
        type: 'input',
        name: 'room',
        message: `Get paid for (1 day, 7 days, 30 days)`,
      },
      {
        type: 'input',
        name: 'sign',
        message: `Sign ${value}`,
      }
    ])

    const worker = await web3.eth.personal.ecRecover(`${value}`, prompt.sign)

    const Salary = artifacts.require('Salary') //salary
    const salary = await Salary.deployed()

    const receivedIsSalary = await salary.receivedIsSalary(prompt.currentSalary, worker)  

    if (receivedIsSalary) {
      console.log(`Issue salary ${prompt.currentSalary} for ${worker}.`) //room

      console.log(`Access until  ${(Number(prompt.currentSalary)*12)} $`)
      process.exit()
    } else {
      console.error('Oh no... We cannot issue salari.')
    }
  }

  run().catch(e => {
    console.error(e)
    process.exit(1)
  })
}




// Use web3.eth.personal.sign(msg, account) to sign from console

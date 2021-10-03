import sql from 'mssql'
import { sqlConfig } from './sql/config.js'

sql.on('error', err=> {
    console.error(err)
})

sql.connect(sqlConfig).then(pool => {
    return pool.request()
    .input('nome', sql.Char(100),'Tubarão')
    .input('ano', sql.Int,'1975')
    .input('categoria', sql.Char(30),'Aventura/Thriller')
    .input('diretor', sql.Char(100),'Steven Spielberg')
    .input('descricao', sql.Char(1000),'Um terrível ataque a banhistas é o sinal de que a praia da pequena cidade de Amity, na Nova Inglaterra, virou refeitório de um gigantesco tubarão branco. O chefe de polícia Martin Brody quer fechar as praias, mas o prefeito Larry Vaughn não permite, com medo de que o faturamento com a receita dos turistas deixe a cidade sem recursos. O cientista Matt Hooper e o pescador Quint se oferecem para ajudar Brody a capturar e matar a fera, mas a missão vai ser mais complicada do que eles imaginavam.')
    .output('codigogerado', sql.Int)
    .execute('SP_I_LOC_FILME')
}) .then(result => {
    console.log(result)
}).catch(err => {
    console.log(err.message)
})
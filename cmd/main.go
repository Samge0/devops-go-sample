package main

import (
    "github.com/gin-gonic/gin"
)

func index(c *gin.Context) {
    c.JSON(200, gin.H{
        "date": "2022-11-25 18:53:25",
        "name": "samge",
        "msg": "Hi guys, this is a devops jenkins test of kebesphere",
        })
}

func test(c *gin.Context) {
    c.JSON(200, gin.H{
        "code": 200,
        "data": "test data",
        "msg": "succeed",
        })
}

func main() {
    r := gin.Default()
    r.GET("/", index)
    api := r.Group("/api")
    {
        api.GET("/test", test)
    }
    r.Run(":8080")
}
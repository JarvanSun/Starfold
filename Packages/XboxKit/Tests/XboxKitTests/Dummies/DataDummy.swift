//
//  DataDummy.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

extension Data {
    static var dummySampleLayoutsBundle: Data {
        let base64 = """
            UEsDBBQAAAAIAFZyN1O8vEpptQAAAPcAAAARAAAAdGFreG1hbmlmZXN0Lmpzb248jkuOwjAQRPdI3CGyZontwJIz
            cImO00kMtht1t/kIzd0HA8OuSvWkeo/1quvMj4QFM5h9ZxbVs+y9Z7i6OepShyrIgYpiURco+xwDk9Ck/jbQzc6Q
            0YoyQo5ltkqUxGcQRfZKNSwWRjgraKRiT1H9+6sxJU4o6i8713+bOwoVs3lpjThBTXqAO1VtcqJQRuDRNh+mlJA/
            aHox0qD/+B4uyPJ8bsPWbV3verNe/f4BAAD//wMAUEsDBBQAAAAIAFZyN1MKZ0QVOgIAAJgLAAAcAAAAbGF5b3V0
            cy9uZXV0cmFsL2RyaXZpbmcuanNvbs1WvZLaMBDuM5N3YJSUgHNJd13uqkuVIsXNZFIssmzrkLUeaXVAMjxZijxS
            XiGSMdgyBjJAQWMk7bI/3/fJ67+///x6+2Y0Yu8tL0QJ7H7ECqLK3ieJgcU0l1S4mbPCcNQkNE05lkkpuUGLGSXL
            GS4nOZRiYskIKKXOJ4SobFKCJWESQseLCaRQEZBEPZlLSja5bKJghY6S10/Tu2Y9fbGo2bguqcnoS6pL9CdKZJ2t
            P5BaC+NPvm9PRq2xdqBVJUJPL7iyJPl8E3pnhqW03YC7sJULiWr7c/wfb/Z1NvZQ0Jcm9L5fKiD9iVrsZwiVFUbY
            AlXqrR+md7F93d2u45otrZQYqjoVGTgVAbSzzTXOhgzelAEXTyXkg2VGIErPSL/JxuUVlKt9POnCeBWwfbeoqYGD
            uM9AQ6qGsfMEKDmMaw2QwfnhbjgqDJph77IsO9AOVsAlrQI146OQWFQyPafXiOB2s1v+2Cy2mDAj8+JM7c8cUZ84
            BjzcxmCuI3/zz9yHu4LUTujppJpaLeVgv4oUFLsYzF2aIJ0+ap1lD8ITIEYwhpdgBennPZdDIB6H8eoXswCdzgzM
            xceL5Rpl0k6pdt8ifaYaGxgfbkuJXKEVZ8twfG2thbEzeGNvR2611IZv7w3K7fm25Cb9h4/xRbJrTxFXVfXbr50i
            27ly6RQphXbsPypQuOhVwP03Xnw0Opa1P7keXBl66noMs3eYu+PMneCt8+mzkMSLR68oAz3mThLVLOof/1j/A1BL
            AwQUAAAACABWcjdTbp7M95oBAADiCAAAHQAAAGxheW91dHMvbmV1dHJhbC9maWdodGluZy5qc29u1ZXNTsJAEMfv
            Jr4DaTxaNuqNm9wMF44a42HYDu3KfjS7swgxPJkHH8lXsFsKLKCBGEjqpd3OzO7859fZzNfH5/vlRaeTXDleoIKk
            10kKotL1GLPw1s0FFX7kHVpuNKGmLjeKKcGtcWZMbDYyszQHhakji6CEzlMyRjqmwBFaRsbzIoUMSgISRqcTQWyZ
            yzEJc+OJTe+6N826++qMTq5rSU3GSlItsbJIHEeflUFojbayPK8snY2zDqB5iaGmTFjkIT/IIWTLBOsgx0GGqNuN
            dbFaviwXi2ZHYkVe/FEDWA4Z9j2R0W5HggzHDr3mRXx244RaeTgikC4he9zeHUqguUS3v7dyZTgGL7c0R94xcHxQ
            kOPP/ki+qP7Hbt4mZArS1zFRGfuBa6a/GLY+V8CbDAoz4dXRgJ7aCiiu47SECoTp/DCgun/7XpVVz7aUUVTJaRHV
            3TkQfHJMC923Fc+minNcsWPx9NuKJyrjDBfsIJ4wov7B9Rqcgs8R49KXgUQ8LlcD9OC4HNWDcmdObkAr1D6qYE9B
            eFWPxTdQSwMEFAAAAAgAVnI3U0sug1a/AgAAOhEAACkAAABsYXlvdXRzL25ldXRyYWwvZmlyc3QtcGVyc29uLXNo
            b290ZXIuanNvbs1YzW7bMAy+D9g7BMaOTbxuGDD01tw2YKf10KDoQbEZW4ksGfpJ4g19sh32SHuF0Y7tyIrStImB
            +iaJjEh++kia+ffn7+/370aj4IOKUshIcDMKUq1zdROGkmwmCdWpmRsFMhJcA9eTSGRhRiMplFjocDsX23FCMhgr
            LYFklCdjLQRTYUaUBhlqYaJ0TGKSa6Kp4OMV1eHOlgoZKYTR4frz5LpeT5ZK8OCqcqm2iC5VLuIJg4W1xQPKOUg8
            eWhORnthpaCLHMqYlqJQmkar3dWtmGypsi9sr81NaaiS38+6P0I5OlorlB59b+62tZ66hpQuGPhMxbAghnWiamUr
            LuY+AYoWJIJvGUnAL7cipwijG0CtsibMVDobwrre1zG4R85BZ2tt2uXjbtFgEUiapGc+YMWjnMT+B7R+fnCF50UP
            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
            tPUHXCk0/uR7f5K8BNsEWjUY7vSgV5Z48biBHsK4bECVPmEBwuI4BktuY7KBsnFBRBu/ux8D+ri/RJcQ1H7dy+vT
            SoTyp1a4yxBU1wZtrUVQdpVffZ7tZBgoOQgfJuNwHF3H22gzLH8McEHsdv2UEyLi29pGiVuljopdcoNFeGwQt1Cm
            E3peZEw92twR9d0wBKFF7uv7rXZyHjGsp6WfzmF4Vfky7Wc5GfbGyWaMOjzQZtGzpJ6/PrHvj+gIk9tAeX/Ou3WY
            N++A+eUdMO/S/x6Rk+jaR9x989k5YA936DnmYENzYNheZQz7XXjSa4+77chvW41ThnvEcl9juodtd8t4k0kf7qZ7
            d8xdE3ojHvN+8N/aexKVO2fTPXF8PmRc4ec/639QSwECFAAUAAAACABWcjdTvLxKabUAAAD3AAAAEQAAAAAAAAAA
            AAAAAAAAAAAAdGFreG1hbmlmZXN0Lmpzb25QSwECFAAUAAAACABWcjdTCmdEFToCAACYCwAAHAAAAAAAAAAAAAAA
            AADkAAAAbGF5b3V0cy9uZXV0cmFsL2RyaXZpbmcuanNvblBLAQIUABQAAAAIAFZyN1Nunsz3mgEAAOIIAAAdAAAA
            AAAAAAAAAAAAAFgDAABsYXlvdXRzL25ldXRyYWwvZmlnaHRpbmcuanNvblBLAQIUABQAAAAIAFZyN1NLLoNWvwIA
            ADoRAAApAAAAAAAAAAAAAAAAAC0FAABsYXlvdXRzL25ldXRyYWwvZmlyc3QtcGVyc29uLXNob290ZXIuanNvblBL
            AQIUABQAAAAIAFZyN1OMmZo5vQEAAHMHAAAmAAAAAAAAAAAAAAAAADMIAABsYXlvdXRzL25ldXRyYWwvcGxhdGZv
            cm1lci1zaW1wbGUuanNvblBLAQIUABQAAAAIAFZyN1PZ5uMHBQIAAKAMAAAfAAAAAAAAAAAAAAAAADQKAABsYXlv
            dXRzL25ldXRyYWwvcGxhdGZvcm1lci5qc29uUEsBAhQAFAAAAAgAVnI3Uw9ivGjRAQAAXggAACgAAAAAAAAAAAAA
            AAAAdgwAAGxheW91dHMvbmV1dHJhbC9zdGFuZGFyZC1jb250cm9sbGVyLmpzb25QSwUGAAAAAAcABwAiAgAAjQ4A
            AAAA
            """
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)!
    }
}
